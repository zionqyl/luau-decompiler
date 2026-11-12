use crate::bytecode::{Opcode, Proto};
use crate::cfg::Cfg;
use crate::dataflow::{Definition, Ssa};
use crate::{Error, Limits, Result};
use serde::Serialize;
use std::collections::BTreeMap;

pub type BindingId = usize;

#[derive(Debug, Clone, Serialize)]
pub struct Binding {
    pub id: BindingId,
    pub register: usize,
    pub first_pc: usize,
    pub last_pc: usize,
    pub debug_name: Option<String>,
    pub parameter: bool,
    pub reference_cell: bool,
}

#[derive(Debug)]
pub struct RecoveredBindings {
    pub bindings: Vec<Binding>,
    pub definition_bindings: Vec<BindingId>,
    pub first_for_register: Vec<BindingId>,
}

struct Groups(Vec<usize>);
impl Groups {
    fn root(&mut self, mut value: usize) -> usize {
        while self.0[value] != value {
            self.0[value] = self.0[self.0[value]];
            value = self.0[value];
        }
        value
    }
    fn join(&mut self, a: usize, b: usize) {
        let (a, b) = (self.root(a), self.root(b));
        if a != b {
            self.0[a.max(b)] = a.min(b);
        }
    }
}

impl RecoveredBindings {
    pub fn analyze(proto: &Proto, cfg: &Cfg, ssa: &Ssa, limits: &Limits) -> Result<Self> {
        crate::execution::checkpoint()?;
        if ssa.definitions.len().saturating_mul(4) > limits.max_analysis_steps {
            return Err(Error::new("limit", "binding definition budget exceeded"));
        }
        let mut groups = Groups((0..ssa.definitions.len()).collect());
        let registers = proto.max_stack as usize;
        let mut reference = vec![false; registers];
        let mut pinned = vec![false; registers];
        for i in &proto.code {
            if i.op == Opcode::Capture && i.a() == 1 {
                reference[i.b()] = true;
                pinned[i.b()] = true;
            }
            let width = match i.op {
                Opcode::ForNPrep | Opcode::ForNLoop => 3,
                Opcode::ForGPrep | Opcode::ForGPrepInext | Opcode::ForGPrepNext => 3,
                Opcode::ForGLoop => 3 + (i.aux.unwrap_or(0) as usize & 255).max(2),
                _ => 0,
            };
            if width != 0 {
                pinned[i.a()..(i.a() + width).min(registers)].fill(true);
            }
        }
        for (value, definition) in ssa.definitions.iter().enumerate() {
            if value & 255 == 0 {
                crate::execution::checkpoint()?;
            }
            match definition {
                Definition::Instruction { register, .. } | Definition::Phi { register, .. }
                    if pinned[*register] =>
                {
                    groups.join(*register, value)
                }
                _ => {}
            }
            if let Definition::Phi {
                block,
                register,
                incoming,
            } = definition
            {
                let first = cfg.blocks[*block].start;
                let live = ssa.effects[first]
                    .reads
                    .union(ssa.live_after[first].difference(ssa.effects[first].writes));
                if live.contains(*register) {
                    for &(_, incoming) in incoming {
                        groups.join(value, incoming);
                    }
                }
            }
        }

        let mut steps = 0usize;
        for local in &proto.locals {
            crate::execution::checkpoint()?;
            let r = local.register as usize;
            let start = proto.code.partition_point(|i| i.pc < local.start_pc);
            if start == proto.code.len() {
                continue;
            }
            let initial = ssa.reaching_definition(cfg, start, r);
            for index in start..proto.code.len() {
                if proto.code[index].pc >= local.end_pc {
                    break;
                }
                steps += 1;
                if steps > limits.max_analysis_steps {
                    return Err(Error::new(
                        "limit",
                        "debug binding interval budget exceeded",
                    ));
                }
                if let Some(value) = ssa.read_definition(index, r) {
                    groups.join(initial, value);
                }
                if let Some(value) = ssa.write_definition(index, r) {
                    groups.join(initial, value);
                }
            }
        }
        let mut roots = BTreeMap::<usize, Binding>::new();
        for (value, definition) in ssa.definitions.iter().enumerate() {
            let (register, pc, parameter) = match definition {
                Definition::Parameter(r) => (*r, 0, true),
                Definition::Instruction { index, register } => {
                    if !cfg.blocks[cfg.instruction_block[*index]].reachable {
                        continue;
                    }
                    (*register, proto.code[*index].pc, false)
                }
                _ => continue,
            };
            let root = groups.root(value);
            let item = roots.entry(root).or_insert(Binding {
                id: 0,
                register,
                first_pc: pc,
                last_pc: pc,
                debug_name: None,
                parameter,
                reference_cell: reference[register],
            });
            item.first_pc = item.first_pc.min(pc);
            item.last_pc = item.last_pc.max(pc);
            item.parameter |= parameter;
        }

        for (r, &reference_cell) in reference.iter().enumerate() {
            if !roots.values().any(|b| b.register == r) {
                roots.insert(
                    groups.root(r),
                    Binding {
                        id: 0,
                        register: r,
                        first_pc: 0,
                        last_pc: 0,
                        debug_name: None,
                        parameter: r < proto.num_params as usize,
                        reference_cell,
                    },
                );
            }
        }
        let mut entries: Vec<_> = roots.into_iter().collect();
        entries.sort_by_key(|(root, b)| (b.first_pc, b.register, *root));
        let mut root_ids = BTreeMap::new();
        let mut bindings = Vec::with_capacity(entries.len());
        for (root, mut binding) in entries {
            binding.id = bindings.len();
            root_ids.insert(root, binding.id);
            bindings.push(binding);
        }
        let mut first_for_register = vec![usize::MAX; registers];
        for binding in &bindings {
            let slot = &mut first_for_register[binding.register];
            if *slot == usize::MAX {
                *slot = binding.id;
            }
        }
        let definition_bindings =
            ssa.definitions
                .iter()
                .enumerate()
                .map(|(value, definition)| {
                    let r = match definition {
                        Definition::Parameter(r) | Definition::Undefined(r) => *r,
                        Definition::Instruction { register, .. }
                        | Definition::Phi { register, .. } => *register,
                    };
                    root_ids
                        .get(&groups.root(value))
                        .copied()
                        .unwrap_or(first_for_register[r])
                })
                .collect::<Vec<_>>();
        for (index, effect) in ssa.effects.iter().enumerate() {
            for r in effect.reads.registers() {
                let id = definition_bindings[ssa.read_definition(index, r).unwrap()];
                bindings[id].last_pc = bindings[id].last_pc.max(proto.code[index].pc);
            }
        }
        for local in &proto.locals {
            let start = proto.code.partition_point(|i| i.pc < local.start_pc);
            if start == proto.code.len() {
                continue;
            }
            let value = ssa.reaching_definition(cfg, start, local.register as usize);
            let id = definition_bindings[value];
            if bindings[id].debug_name.is_none() {
                bindings[id].debug_name = Some(local.name.clone());
            }
        }
        Ok(Self {
            bindings,
            definition_bindings,
            first_for_register,
        })
    }

    pub fn read(&self, ssa: &Ssa, index: usize, r: usize) -> BindingId {
        ssa.read_definition(index, r)
            .or_else(|| ssa.write_definition(index, r))
            .map(|value| self.definition_bindings[value])
            .unwrap_or(self.first_for_register[r])
    }
    pub fn write(&self, ssa: &Ssa, index: usize, r: usize) -> BindingId {
        ssa.write_definition(index, r)
            .or_else(|| ssa.read_definition(index, r))
            .map(|value| self.definition_bindings[value])
            .unwrap_or(self.first_for_register[r])
    }
}
