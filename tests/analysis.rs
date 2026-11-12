use luau_decompiler::{
    bytecode,
    cfg::Cfg,
    dataflow::{Definition, Ssa},
    Limits,
};
use std::fs;
use std::path::Path;

#[test]
fn compiler_cfg_and_ssa_invariants() {
    let directory = Path::new(env!("CARGO_MANIFEST_DIR")).join("tests/fixtures");
    let mut fixtures: Vec<_> = fs::read_dir(directory)
        .unwrap()
        .map(|e| e.unwrap().path())
        .filter(|p| p.extension().is_some_and(|e| e == "bc"))
        .collect();
    fixtures.sort();
    assert!(!fixtures.is_empty());
    let limits = Limits::default();
    let mut saw_phi = false;
    let mut saw_backedge = false;
    for path in fixtures {
        let bytes = fs::read(&path).unwrap();
        let module = bytecode::decode(&bytes, &limits).unwrap();
        for (proto_id, proto) in module.protos.iter().enumerate() {
            let cfg = Cfg::build(proto, &limits)
                .unwrap_or_else(|e| panic!("{} proto{proto_id}: {e}", path.display()));
            let ssa = Ssa::analyze(proto, &cfg, &limits)
                .unwrap_or_else(|e| panic!("{} proto{proto_id}: {e}", path.display()));
            assert!(cfg.blocks[0].reachable);
            for (id, block) in cfg.blocks.iter().enumerate() {
                assert!(block.start < block.end && block.end <= proto.code.len());
                for &successor in &block.successors {
                    assert!(cfg.blocks[successor].predecessors.contains(&id));
                }
                if id > 0 && block.reachable {
                    assert!(cfg.immediate_dominators[id].is_some());
                }
            }
            for &(source, target) in &cfg.back_edges {
                saw_backedge = true;
                let mut ancestor = source;
                for _ in 0..=cfg.blocks.len() {
                    if ancestor == target {
                        break;
                    }
                    let parent = cfg.immediate_dominators[ancestor].expect("reachable backedge");
                    assert_ne!(parent, ancestor, "backedge target must dominate source");
                    ancestor = parent;
                }
                assert_eq!(ancestor, target);
            }
            for definition in &ssa.definitions {
                if let Definition::Phi {
                    block,
                    register,
                    incoming,
                } = definition
                {
                    saw_phi = true;
                    assert!(*register < proto.max_stack as usize);
                    for &(pred, value) in incoming {
                        assert!(
                            cfg.blocks[*block].predecessors.contains(&pred)
                                || (*block == 0
                                    && pred == luau_decompiler::dataflow::ENTRY_PREDECESSOR)
                        );
                        assert!(value < ssa.definitions.len());
                    }
                }
            }
        }
    }
    assert!(
        saw_phi && saw_backedge,
        "corpus must exercise merges and loops"
    );
}
