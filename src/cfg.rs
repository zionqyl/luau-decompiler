use crate::bytecode::{Instruction, Opcode, Proto};
use crate::{Error, Limits, Result};
use std::collections::{BTreeSet, VecDeque};

#[derive(Debug, Clone)]
pub struct Block {
    pub start: usize,
    pub end: usize,
    pub successors: Vec<usize>,
    pub predecessors: Vec<usize>,
    pub reachable: bool,
}

#[derive(Debug)]
pub struct Cfg {
    pub blocks: Vec<Block>,
    pub instruction_block: Vec<usize>,
    pub immediate_dominators: Vec<Option<usize>>,
    pub back_edges: Vec<(usize, usize)>,
}

pub fn is_conditional(op: Opcode) -> bool {
    use Opcode::*;
    matches!(
        op,
        JumpIf
            | JumpIfNot
            | JumpIfEq
            | JumpIfLe
            | JumpIfLt
            | JumpIfNotEq
            | JumpIfNotLe
            | JumpIfNotLt
            | JumpXEqKNil
            | JumpXEqKB
            | JumpXEqKN
            | JumpXEqKS
    )
}

pub fn jump_target(i: &Instruction) -> Option<usize> {
    use Opcode::*;
    let displacement = match i.op {
        Jump | JumpBack | JumpIf | JumpIfNot | JumpIfEq | JumpIfLe | JumpIfLt | JumpIfNotEq
        | JumpIfNotLe | JumpIfNotLt | ForNPrep | ForNLoop | ForGLoop | ForGPrep | ForGPrepInext
        | ForGPrepNext | JumpXEqKNil | JumpXEqKB | JumpXEqKN | JumpXEqKS => i.d() as i64,
        JumpX => i.e() as i64,
        LoadB if i.c() != 0 => i.c() as i64,
        _ => return None,
    };
    usize::try_from(i.pc as i64 + 1 + displacement).ok()
}

pub fn is_unconditional(op: Opcode) -> bool {
    use Opcode::*;
    matches!(
        op,
        Jump | JumpBack | JumpX | ForGPrep | ForGPrepInext | ForGPrepNext
    )
}

impl Cfg {
    pub fn build(proto: &Proto, limits: &Limits) -> Result<Self> {
        crate::execution::checkpoint()?;
        if proto.code.is_empty() {
            return Err(Error::new("cfg", "function contains no instructions"));
        }
        let code = &proto.code;
        let by_pc = |pc: usize| {
            code.binary_search_by_key(&pc, |i| i.pc).map_err(|_| {
                Error::new(
                    "cfg",
                    format!("branch target {pc} is not an instruction header"),
                )
            })
        };
        let mut leaders = BTreeSet::from([0]);
        for (index, i) in code.iter().enumerate() {
            if index & 255 == 0 {
                crate::execution::checkpoint()?;
            }
            if let Some(target) = jump_target(i) {
                leaders.insert(by_pc(target).map_err(|e| e.at_pc(i.pc))?);
                if index + 1 < code.len() {
                    leaders.insert(index + 1);
                }
            } else if i.op == Opcode::Return && index + 1 < code.len() {
                leaders.insert(index + 1);
            }
        }
        if leaders.len() > limits.max_blocks {
            return Err(Error::new(
                "limit",
                format!(
                    "basic-block count {} exceeds {}",
                    leaders.len(),
                    limits.max_blocks
                ),
            ));
        }
        let leaders: Vec<_> = leaders.into_iter().collect();
        let mut instruction_block = vec![0; code.len()];
        let mut blocks = Vec::with_capacity(leaders.len());
        for (id, &start) in leaders.iter().enumerate() {
            let end = leaders.get(id + 1).copied().unwrap_or(code.len());
            instruction_block[start..end].fill(id);
            blocks.push(Block {
                start,
                end,
                successors: Vec::new(),
                predecessors: Vec::new(),
                reachable: false,
            });
        }
        for block in &mut blocks {
            let index = block.end - 1;
            let i = &code[index];
            if let Some(target) = jump_target(i) {
                block.successors.push(instruction_block[by_pc(target)?]);
            }
            let falls_through = i.op != Opcode::Return
                && !is_unconditional(i.op)
                && !(i.op == Opcode::LoadB && i.c() != 0);
            if falls_through {
                if index + 1 == code.len() {
                    return Err(
                        Error::new("cfg", "execution falls off the end of a function").at_pc(i.pc),
                    );
                }
                let successor = instruction_block[index + 1];
                if !block.successors.contains(&successor) {
                    block.successors.push(successor);
                }
            }
        }
        for id in 0..blocks.len() {
            for successor in blocks[id].successors.clone() {
                blocks[successor].predecessors.push(id);
            }
        }
        let mut queue = VecDeque::from([0]);
        blocks[0].reachable = true;
        while let Some(id) = queue.pop_front() {
            crate::execution::checkpoint()?;
            for successor in blocks[id].successors.clone() {
                if !blocks[successor].reachable {
                    blocks[successor].reachable = true;
                    queue.push_back(successor);
                }
            }
        }

        let mut postorder = Vec::new();
        let mut seen = vec![false; blocks.len()];
        let mut stack = vec![(0, false)];
        while let Some((id, visited)) = stack.pop() {
            if visited {
                postorder.push(id);
                continue;
            }
            if seen[id] {
                continue;
            }
            seen[id] = true;
            stack.push((id, true));
            for &next in blocks[id].successors.iter().rev() {
                if !seen[next] {
                    stack.push((next, false));
                }
            }
        }
        postorder.reverse();
        let mut rank = vec![usize::MAX; blocks.len()];
        for (n, &id) in postorder.iter().enumerate() {
            rank[id] = n;
        }
        let mut idom = vec![None; blocks.len()];
        idom[0] = Some(0);
        let mut changed = true;
        let mut steps = 0usize;
        while changed {
            crate::execution::checkpoint()?;
            changed = false;
            for &id in postorder.iter().skip(1) {
                let mut incoming = blocks[id]
                    .predecessors
                    .iter()
                    .copied()
                    .filter(|&p| idom[p].is_some());
                let Some(mut candidate) = incoming.next() else {
                    continue;
                };
                for mut p in incoming {
                    while candidate != p {
                        steps += 1;
                        if steps > limits.max_analysis_steps {
                            return Err(Error::new("limit", "dominator analysis budget exceeded"));
                        }
                        if rank[candidate] > rank[p] {
                            candidate = idom[candidate].unwrap();
                        } else {
                            p = idom[p].unwrap();
                        }
                    }
                }
                if idom[id] != Some(candidate) {
                    idom[id] = Some(candidate);
                    changed = true;
                }
            }
        }
        let mut back_edges = Vec::new();
        for (id, block) in blocks.iter().enumerate().filter(|(_, b)| b.reachable) {
            for &successor in &block.successors {
                let mut ancestor = id;
                loop {
                    if ancestor == successor {
                        back_edges.push((id, successor));
                        break;
                    }
                    let Some(parent) = idom[ancestor] else {
                        break;
                    };
                    if parent == ancestor {
                        break;
                    }
                    ancestor = parent;
                    steps += 1;
                    if steps > limits.max_analysis_steps {
                        return Err(Error::new("limit", "loop analysis budget exceeded"));
                    }
                }
            }
        }
        Ok(Self {
            blocks,
            instruction_block,
            immediate_dominators: idom,
            back_edges,
        })
    }
}
