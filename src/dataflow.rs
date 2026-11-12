use crate::bytecode::{Opcode, Proto};
use crate::cfg::Cfg;
use crate::{Error, Limits, Result};
use std::collections::VecDeque;

#[derive(Debug, Clone, Copy, Default, PartialEq, Eq)]
pub struct RegisterSet(pub [u64; 4]);
impl RegisterSet {
    pub fn insert(&mut self, r: usize) {
        self.0[r / 64] |= 1u64 << (r % 64);
    }
    pub fn remove(&mut self, r: usize) {
        self.0[r / 64] &= !(1u64 << (r % 64));
    }
    pub fn contains(self, r: usize) -> bool {
        self.0[r / 64] & (1u64 << (r % 64)) != 0
    }
    pub fn union(self, other: Self) -> Self {
        let mut out = self;
        for i in 0..4 {
            out.0[i] |= other.0[i];
        }
        out
    }
    pub fn intersection(self, other: Self) -> Self {
        let mut out = self;
        for i in 0..4 {
            out.0[i] &= other.0[i];
        }
        out
    }
    pub fn difference(self, other: Self) -> Self {
        let mut out = self;
        for i in 0..4 {
            out.0[i] &= !other.0[i];
        }
        out
    }
    pub fn registers(self) -> impl Iterator<Item = usize> {
        let mut words = self.0;
        words[3] &= u64::MAX >> 1;
        words.into_iter().enumerate().flat_map(|(word, mut bits)| {
            std::iter::from_fn(move || {
                if bits == 0 {
                    return None;
                }
                let bit = bits.trailing_zeros() as usize;
                bits &= bits - 1;
                Some(word * 64 + bit)
            })
        })
    }
    fn range(start: usize, end: usize) -> Self {
        let mut out = Self::default();
        for r in start..end {
            out.insert(r);
        }
        out
    }
}

#[derive(Debug, Clone, Copy, Default)]
pub struct Effects {
    pub reads: RegisterSet,
    pub writes: RegisterSet,
}

pub fn effects(proto: &Proto, index: usize) -> Effects {
    use Opcode::*;
    let i = &proto.code[index];
    let (a, b, c) = (i.a(), i.b(), i.c());
    let mut e = Effects::default();
    let mut read = |r| e.reads.insert(r);
    match i.op {
        Move | Not | Minus | Length | GetTableKs | GetTableN => read(b),
        GetTable | Add | Sub | Mul | Div | Mod | Pow | And | Or | IDiv => {
            read(b);
            read(c);
        }
        AddK | SubK | MulK | DivK | ModK | PowK | AndK | OrK | IDivK => read(b),
        SubRk | DivRk => read(c),
        SetGlobal | SetUpval | JumpIf | JumpIfNot | JumpXEqKNil | JumpXEqKB | JumpXEqKN
        | JumpXEqKS => read(a),
        SetTable => {
            read(a);
            read(b);
            read(c);
        }
        SetTableKs | SetTableN => {
            read(a);
            read(b);
        }
        JumpIfEq | JumpIfLe | JumpIfLt | JumpIfNotEq | JumpIfNotLe | JumpIfNotLt => {
            read(a);
            read(i.aux.unwrap_or(0) as usize);
        }
        NameCall => read(b),
        Concat => {
            for r in b..=c {
                read(r);
            }
        }
        ForNPrep | ForNLoop | ForGPrep | ForGPrepInext | ForGPrepNext | ForGLoop => {
            for r in a..a + 3 {
                read(r);
            }
        }
        Call => {
            read(a);
            let end = if b != 0 {
                a + b
            } else {
                previous_open_base(proto, index).unwrap_or(a + 1)
            };
            for r in a + 1..end {
                read(r);
            }
        }
        Return => {
            let end = if b != 0 {
                a + b - 1
            } else {
                previous_open_base(proto, index).unwrap_or(a)
            };
            for r in a..end {
                read(r);
            }
        }
        SetList => {
            read(a);
            let end = if c != 0 {
                b + c - 1
            } else {
                previous_open_base(proto, index).unwrap_or(b)
            };
            for r in b..end {
                read(r);
            }
        }
        Capture if a <= 1 => read(b),
        _ => {}
    }
    let mut write = |r| e.writes.insert(r);
    match i.op {
        LoadNil | LoadB | LoadN | LoadK | Move | GetGlobal | GetUpval | GetImport | GetTable
        | GetTableKs | GetTableN | NewClosure | Add | Sub | Mul | Div | Mod | Pow | AddK | SubK
        | MulK | DivK | ModK | PowK | And | Or | AndK | OrK | Concat | Not | Minus | Length
        | NewTable | DupTable | DupClosure | LoadKx | SubRk | DivRk | IDiv | IDivK => write(a),
        NameCall => {
            write(a);
            write(a + 1);
        }
        Call if c != 0 => {
            for r in a..a + c - 1 {
                write(r);
            }
        }
        GetVarargs if b != 0 => {
            for r in a..a + b - 1 {
                write(r);
            }
        }
        ForNPrep | ForGPrep | ForGPrepInext | ForGPrepNext => {
            for r in a..a + 3 {
                write(r);
            }
        }
        ForNLoop => write(a + 2),
        ForGLoop => {
            write(a + 2);
            for r in a + 3..a + 3 + (i.aux.unwrap_or(0) as usize & 255) {
                write(r);
            }
        }
        _ => {}
    }
    e
}

fn previous_open_base(proto: &Proto, index: usize) -> Option<usize> {
    for i in proto.code[..index].iter().rev() {
        if (i.op == Opcode::Call && i.c() == 0) || (i.op == Opcode::GetVarargs && i.b() == 0) {
            return Some(i.a());
        }
        if !matches!(
            i.op,
            Opcode::FastCall
                | Opcode::FastCall1
                | Opcode::FastCall2
                | Opcode::FastCall2K
                | Opcode::FastCall3
                | Opcode::FastPcall
                | Opcode::GetImport
                | Opcode::CloseUpvals
                | Opcode::NameCall
        ) {
            break;
        }
    }
    None
}

pub type ValueId = usize;

pub const ENTRY_PREDECESSOR: usize = usize::MAX;
#[derive(Debug, Clone)]
pub enum Definition {
    Parameter(usize),
    Undefined(usize),
    Instruction {
        index: usize,
        register: usize,
    },
    Phi {
        block: usize,
        register: usize,
        incoming: Vec<(usize, ValueId)>,
    },
}
#[derive(Debug)]
pub struct Ssa {
    pub definitions: Vec<Definition>,
    pub block_inputs: Vec<Vec<ValueId>>,
    pub block_outputs: Vec<Vec<ValueId>>,
    pub live_after: Vec<RegisterSet>,
    pub effects: Vec<Effects>,

    pub open_captures_before: Vec<RegisterSet>,
    instruction_def_starts: Vec<usize>,
    read_def_starts: Vec<usize>,
    read_definitions: Vec<ValueId>,
}

impl Ssa {
    pub fn analyze(proto: &Proto, cfg: &Cfg, limits: &Limits) -> Result<Self> {
        crate::execution::checkpoint()?;
        let registers = proto.max_stack as usize;
        if cfg.blocks.len().saturating_mul(registers) > limits.max_analysis_steps {
            return Err(Error::new(
                "limit",
                "SSA block/register product exceeds analysis budget",
            ));
        }
        let all = RegisterSet::range(0, registers);
        let parameters = RegisterSet::range(0, proto.num_params as usize);
        let fx: Vec<_> = (0..proto.code.len()).map(|i| effects(proto, i)).collect();
        let count = cfg.blocks.len();
        let mut definite_in = vec![all; count];
        let mut definite_out = vec![all; count];
        definite_in[0] = parameters;
        let mut queue: VecDeque<_> = (0..count).filter(|&id| cfg.blocks[id].reachable).collect();
        let mut pending = vec![true; count];
        let mut steps = 0usize;
        while let Some(id) = queue.pop_front() {
            crate::execution::checkpoint()?;
            pending[id] = false;
            let block = &cfg.blocks[id];
            let mut input = if id == 0 { parameters } else { all };
            for &pred in &block.predecessors {
                if cfg.blocks[pred].reachable {
                    input = input.intersection(definite_out[pred]);
                }
            }
            definite_in[id] = input;
            let mut output = input;
            for effect in &fx[block.start..block.end] {
                output = output.union(effect.writes);
                steps += 1;
            }
            if steps > limits.max_analysis_steps {
                return Err(Error::new(
                    "limit",
                    "definite-assignment analysis budget exceeded",
                ));
            }
            if output != definite_out[id] {
                definite_out[id] = output;
                for &next in &block.successors {
                    if !pending[next] {
                        pending[next] = true;
                        queue.push_back(next);
                    }
                }
            }
        }
        for (id, block) in cfg.blocks.iter().enumerate().filter(|(_, b)| b.reachable) {
            let mut initialized = definite_in[id];
            for (index, effect) in fx.iter().enumerate().take(block.end).skip(block.start) {
                for r in effect.reads.registers() {
                    if !initialized.contains(r) {
                        return Err(Error::new(
                            "dataflow",
                            format!("register r{r} may be read before initialization"),
                        )
                        .at_pc(proto.code[index].pc));
                    }
                }
                initialized = initialized.union(effect.writes);
            }
        }
        let mut use_set = vec![RegisterSet::default(); count];
        let mut def_set = vec![RegisterSet::default(); count];
        for (id, block) in cfg.blocks.iter().enumerate() {
            for effect in &fx[block.start..block.end] {
                use_set[id] = use_set[id].union(effect.reads.difference(def_set[id]));
                def_set[id] = def_set[id].union(effect.writes);
            }
        }
        let mut live_in = vec![RegisterSet::default(); count];
        let mut live_out = live_in.clone();
        let mut changed = true;
        while changed {
            crate::execution::checkpoint()?;
            changed = false;
            for id in (0..count).rev().filter(|&id| cfg.blocks[id].reachable) {
                let output = cfg.blocks[id]
                    .successors
                    .iter()
                    .fold(RegisterSet::default(), |set, &s| set.union(live_in[s]));
                let input = use_set[id].union(output.difference(def_set[id]));
                steps += 1;
                if steps > limits.max_analysis_steps {
                    return Err(Error::new("limit", "liveness analysis budget exceeded"));
                }
                if input != live_in[id] || output != live_out[id] {
                    changed = true;
                    live_in[id] = input;
                    live_out[id] = output;
                }
            }
        }
        let mut live_after = vec![RegisterSet::default(); proto.code.len()];
        for (id, block) in cfg.blocks.iter().enumerate() {
            let mut live = live_out[id];
            for index in (block.start..block.end).rev() {
                live_after[index] = live;
                live = fx[index].reads.union(live.difference(fx[index].writes));
            }
        }
        let write_count: usize = fx
            .iter()
            .map(|e| {
                e.writes
                    .0
                    .iter()
                    .map(|w| w.count_ones() as usize)
                    .sum::<usize>()
            })
            .sum();
        if write_count > limits.max_analysis_steps {
            return Err(Error::new(
                "limit",
                "SSA definition count exceeds analysis budget",
            ));
        }
        let mut definitions = Vec::with_capacity(registers + write_count);
        definitions.extend((0..registers).map(|r| {
            if r < proto.num_params as usize {
                Definition::Parameter(r)
            } else {
                Definition::Undefined(r)
            }
        }));

        let mut instruction_def_starts = Vec::with_capacity(fx.len());
        for (index, effect) in fx.iter().enumerate() {
            instruction_def_starts.push(definitions.len());
            for register in effect.writes.registers() {
                definitions.push(Definition::Instruction { index, register });
            }
        }
        let initial: Vec<_> = (0..registers).collect();
        let mut inputs = vec![initial.clone(); count];
        let mut outputs = inputs.clone();
        let mut phi = vec![vec![None; registers]; count];
        let mut changed = true;
        while changed {
            crate::execution::checkpoint()?;
            changed = false;
            for (id, block) in cfg.blocks.iter().enumerate().filter(|(_, b)| b.reachable) {
                let preds = &block.predecessors;
                let mut input = initial.clone();
                if let Some(&first_pred) = preds.iter().find(|&&p| cfg.blocks[p].reachable) {
                    for r in 0..registers {
                        steps += 1;
                        if steps > limits.max_analysis_steps {
                            return Err(Error::new("limit", "SSA construction budget exceeded"));
                        }
                        let first = if id == 0 {
                            initial[r]
                        } else {
                            outputs[first_pred][r]
                        };
                        let differs = preds
                            .iter()
                            .filter(|&&p| cfg.blocks[p].reachable)
                            .any(|&p| outputs[p][r] != first);
                        if differs || phi[id][r].is_some() {
                            let value = *phi[id][r].get_or_insert_with(|| {
                                let value = definitions.len();
                                definitions.push(Definition::Phi {
                                    block: id,
                                    register: r,
                                    incoming: Vec::new(),
                                });
                                value
                            });
                            input[r] = value;
                            if let Definition::Phi { incoming, .. } = &mut definitions[value] {
                                incoming.clear();
                                if id == 0 {
                                    incoming.push((ENTRY_PREDECESSOR, initial[r]));
                                }
                                incoming.extend(
                                    preds
                                        .iter()
                                        .filter(|&&p| cfg.blocks[p].reachable)
                                        .map(|&p| (p, outputs[p][r])),
                                );
                            }
                        } else {
                            input[r] = first;
                        }
                    }
                }
                let mut output = input.clone();
                for index in block.start..block.end {
                    for (offset, register) in fx[index].writes.registers().enumerate() {
                        output[register] = instruction_def_starts[index] + offset;
                    }
                }
                if inputs[id] != input || outputs[id] != output {
                    inputs[id] = input;
                    outputs[id] = output;
                    changed = true;
                }
            }
        }
        let mut capture_in = vec![RegisterSet::default(); count];
        let mut capture_out = capture_in.clone();
        let mut changed = true;
        while changed {
            crate::execution::checkpoint()?;
            changed = false;
            for (id, block) in cfg
                .blocks
                .iter()
                .enumerate()
                .filter(|(_, block)| block.reachable)
            {
                let input = block
                    .predecessors
                    .iter()
                    .fold(RegisterSet::default(), |set, &pred| {
                        set.union(capture_out[pred])
                    });
                let mut output = input;
                for index in block.start..block.end {
                    steps += 1;
                    if steps > limits.max_analysis_steps {
                        return Err(Error::new(
                            "limit",
                            "capture lifetime analysis budget exceeded",
                        ));
                    }
                    let i = proto.code[index];
                    if i.op == Opcode::Capture && i.a() == 1 {
                        output.insert(i.b());
                    }
                    if i.op == Opcode::CloseUpvals {
                        output = output.difference(RegisterSet::range(i.a(), registers));
                    }
                }
                if input != capture_in[id] || output != capture_out[id] {
                    capture_in[id] = input;
                    capture_out[id] = output;
                    changed = true;
                }
            }
        }
        let mut open_captures_before = vec![RegisterSet::default(); proto.code.len()];
        for (id, block) in cfg.blocks.iter().enumerate() {
            let mut open = capture_in[id];
            for (index, i) in proto
                .code
                .iter()
                .enumerate()
                .take(block.end)
                .skip(block.start)
            {
                open_captures_before[index] = open;
                if i.op == Opcode::Capture && i.a() == 1 {
                    open.insert(i.b());
                }
                if i.op == Opcode::CloseUpvals {
                    open = open.difference(RegisterSet::range(i.a(), registers));
                }
            }
        }
        let read_count: usize = fx.iter().map(|e| e.reads.registers().count()).sum();
        if read_count > limits.max_analysis_steps {
            return Err(Error::new(
                "limit",
                "SSA read count exceeds analysis budget",
            ));
        }
        let mut read_def_starts = vec![0; fx.len()];
        let mut read_definitions = Vec::with_capacity(read_count);

        for (id, block) in cfg.blocks.iter().enumerate() {
            let mut values = inputs[id].clone();
            for index in block.start..block.end {
                read_def_starts[index] = read_definitions.len();
                read_definitions.extend(fx[index].reads.registers().map(|r| values[r]));
                for (offset, r) in fx[index].writes.registers().enumerate() {
                    values[r] = instruction_def_starts[index] + offset;
                }
            }
        }
        Ok(Self {
            definitions,
            block_inputs: inputs,
            block_outputs: outputs,
            live_after,
            effects: fx,
            open_captures_before,
            instruction_def_starts,
            read_def_starts,
            read_definitions,
        })
    }

    pub fn read_definition(&self, index: usize, register: usize) -> Option<ValueId> {
        let reads = self.effects[index].reads;
        reads
            .contains(register)
            .then(|| self.read_definitions[self.read_def_starts[index] + rank(reads, register)])
    }

    pub fn write_definition(&self, index: usize, register: usize) -> Option<ValueId> {
        let writes = self.effects[index].writes;
        writes
            .contains(register)
            .then(|| self.instruction_def_starts[index] + rank(writes, register))
    }

    pub fn reaching_definition(&self, cfg: &Cfg, index: usize, register: usize) -> ValueId {
        if let Some(value) = self.read_definition(index, register) {
            return value;
        }
        let block = cfg.instruction_block[index];
        for previous in (cfg.blocks[block].start..index).rev() {
            if let Some(value) = self.write_definition(previous, register) {
                return value;
            }
        }
        self.block_inputs[block][register]
    }
}

fn rank(set: RegisterSet, register: usize) -> usize {
    let word = register / 64;
    set.0[..word]
        .iter()
        .map(|w| w.count_ones() as usize)
        .sum::<usize>()
        + (set.0[word] & ((1u64 << (register % 64)).wrapping_sub(1))).count_ones() as usize
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn register_set_handles_all_encodable_registers() {
        let set = RegisterSet::range(0, 255);
        assert_eq!(set.registers().count(), 255);
        assert!(set.contains(254));
        assert_eq!(
            set.difference(RegisterSet::range(10, 250))
                .registers()
                .count(),
            15
        );
    }

    #[test]
    fn entry_block_loop_merges_invocation_parameters_and_backedge() {
        use crate::bytecode::Instruction;
        let instruction = |pc, op: Opcode, word| Instruction {
            pc,
            op,
            word: word | op as u32,
            aux: None,
        };
        let proto = Proto {
            type_metadata: Default::default(),
            max_stack: 1,
            num_params: 1,
            num_upvalues: 0,
            is_vararg: false,
            flags: 0,
            code: vec![
                instruction(0, Opcode::JumpIfNot, 2 << 16),
                instruction(1, Opcode::LoadNil, 0),
                instruction(2, Opcode::JumpBack, 0xfffd << 16),
                instruction(3, Opcode::Return, 2 << 16),
            ],
            constants: vec![],
            children: vec![],
            line_defined: 0,
            debug_name: None,
            locals: vec![],
            upvalue_names: vec![],
        };
        let limits = Limits::default();
        let cfg = Cfg::build(&proto, &limits).unwrap();
        let ssa = Ssa::analyze(&proto, &cfg, &limits).unwrap();
        let value = ssa.block_inputs[0][0];
        let Definition::Phi {
            block,
            register,
            incoming,
        } = &ssa.definitions[value]
        else {
            panic!("loop needs an entry phi")
        };
        assert_eq!((*block, *register), (0, 0));
        assert!(incoming.contains(&(ENTRY_PREDECESSOR, 0)));
        assert_eq!(incoming.len(), 2);
    }

    #[test]
    fn future_reference_capture_does_not_taint_earlier_register_reuse() {
        use crate::bytecode::Instruction;
        let instruction = |pc, op: Opcode, word| Instruction {
            pc,
            op,
            word: word | op as u32,
            aux: None,
        };
        let proto = Proto {
            type_metadata: Default::default(),
            max_stack: 2,
            num_params: 0,
            num_upvalues: 0,
            is_vararg: false,
            flags: 0,
            code: vec![
                instruction(0, Opcode::LoadN, 1 << 16),
                instruction(1, Opcode::NewClosure, 1 << 8),
                instruction(2, Opcode::Capture, 1 << 8),
                instruction(3, Opcode::LoadN, 2 << 16),
                instruction(4, Opcode::CloseUpvals, 0),
                instruction(5, Opcode::Return, 2 << 16),
            ],
            constants: vec![],
            children: vec![0],
            line_defined: 0,
            debug_name: None,
            locals: vec![],
            upvalue_names: vec![],
        };
        let limits = Limits::default();
        let cfg = Cfg::build(&proto, &limits).unwrap();
        let ssa = Ssa::analyze(&proto, &cfg, &limits).unwrap();
        assert!(!ssa.open_captures_before[0].contains(0));
        assert!(!ssa.open_captures_before[2].contains(0));
        assert!(ssa.open_captures_before[3].contains(0));
        assert!(ssa.open_captures_before[4].contains(0));
        assert!(!ssa.open_captures_before[5].contains(0));
    }
}
