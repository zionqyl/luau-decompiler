#[path = "support/generator.rs"]
mod generator;
mod support;
use serde_json::json;
use std::{fs, path::Path};
use support::{digest, Toolset};

fn legacy_source_preservation_evidence() -> serde_json::Value {
    let catalog_bytes = include_bytes!("support/legacy-v2-source-hashes.json");
    let catalog: serde_json::Value = serde_json::from_slice(catalog_bytes).unwrap();
    assert_eq!(catalog["schema"], 1);
    assert_eq!(catalog["baseline_version"], "0.2.0");
    assert_eq!(
        catalog["baseline_archive_sha256"],
        "cff3e8d5572824db99078c2f1ff7e5be7dcbd29001ed287bfc5e4cb8c3a21030"
    );
    let archived_reports = catalog["archived_reports"].as_array().unwrap();
    assert_eq!(archived_reports.len(), 2);
    for report in archived_reports {
        assert_eq!(
            report["sha256"],
            "61d7d34b1eff7fc5801886d7745228da8ad1cbf7770c47e2f4c10005a3b9f785"
        );
        assert!(report["entry"]
            .as_str()
            .unwrap()
            .ends_with("docs/results/generated-programs.json"));
    }
    let sources = catalog["sources"].as_array().unwrap();
    assert_eq!(sources.len(), 128);
    assert_eq!(sources.len(), generator::PROGRAMS);
    let mut matched = 0;
    let mut mismatches = Vec::new();
    for (index, source) in sources.iter().enumerate() {
        assert_eq!(source["index"], index);
        assert_eq!(source["archived_compiler_cases"], 4);
        let expected = source["source_sha256"].as_str().unwrap();
        assert_eq!(expected.len(), 64);
        let current = digest(generator::program(index).as_bytes());
        if current == expected {
            matched += 1;
        } else {
            mismatches.push(json!({"index":index,"expected_source_sha256":expected,"actual_source_sha256":current}));
        }
    }
    let preserved = matched == sources.len();
    assert!(preserved, "v0.2 source identities changed: {mismatches:?}");
    json!({"preserved":preserved,"expected_sources":sources.len(),"matched_sources":matched,"golden_catalog":"tests/support/legacy-v2-source-hashes.json","golden_catalog_sha256":digest(catalog_bytes),"baseline_archive_sha256":catalog["baseline_archive_sha256"],"archived_reports":archived_reports})
}

#[test]
fn legacy_sources_match_archived_v2_release_hashes() {
    let evidence = legacy_source_preservation_evidence();
    assert_eq!(evidence["matched_sources"], 128);
}

fn inputs() -> Vec<Vec<support::oracle::Value>> {
    use support::oracle::Value;
    vec![
        vec![
            Value::Number((-3.0f64).to_bits()),
            Value::String(vec![0, 255, 9]),
        ],
        vec![Value::Number(0.0f64.to_bits()), Value::Nil],
        vec![
            Value::Number(7.0f64.to_bits()),
            Value::String(b"seed\tvalue\n".to_vec()),
        ],
    ]
}

#[test]
fn generator_is_reproducible_and_varies_its_valid_grammar() {
    assert_eq!(
        generator::PROGRAMS,
        128,
        "required v0.2 source catalog must not shrink"
    );
    let hashes: std::collections::BTreeSet<_> = (0..generator::PROGRAMS)
        .map(|index| digest(generator::program(index).as_bytes()))
        .collect();
    assert_eq!(hashes.len(), generator::PROGRAMS);
    assert_eq!(generator::program(73), generator::program(73));
    assert!(generator::program(2).contains("repeat"));
    assert!(generator::program(5).contains("counter"));
    assert!(generator::program(6).contains("select"));
    for family in 0..generator::FAMILIES.len() {
        assert_eq!(
            generator::program_from_axes(family, 41),
            generator::program_from_axes(family, 41)
        );
        assert_ne!(
            generator::program_from_axes(family, 41),
            generator::program_from_axes(family, 73)
        );
    }
    let independent: std::collections::BTreeSet<_> = (0..generator::FAMILIES.len())
        .flat_map(|family| {
            [41, 73]
                .into_iter()
                .map(move |seed| digest(generator::program_from_axes(family, seed).as_bytes()))
        })
        .collect();
    assert_eq!(independent.len(), 16);
}

#[test]
#[ignore = "requires pinned v6/v14 compilers and typed VMs; mandatory generated-program gate"]
fn generated_valid_programs_behavior() {
    let legacy_preservation = legacy_source_preservation_evidence();
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let artifacts = root.join("artifacts/generated-programs");
    fs::create_dir_all(&artifacts).unwrap();
    let input_sets = inputs();
    let mut results = Vec::new();
    let mut failures = Vec::new();
    let tools = [Toolset::checked(root, 6), Toolset::checked(root, 14)];
    for index in 0..generator::PROGRAMS {
        let source = generator::program(index);
        let source_path = artifacts.join(format!("program-{index:03}.luau"));
        fs::write(&source_path, &source).unwrap();
        for toolset in &tools {
            for optimization in [0, 2] {
                for debug in [0, 2] {
                    let directory = artifacts.join(format!(
                        "program-{index:03}/{}/O{optimization}D{debug}",
                        toolset.profile
                    ));
                    match toolset.differential(&source_path,&directory,optimization,debug,&input_sets) {
                Ok(evidence)=>results.push(json!({"case_id":format!("legacy-{index:03}/{}/O{optimization}D{debug}",toolset.profile),"family":generator::FAMILIES[index%generator::FAMILIES.len()],"generator_seed":index,"source_sha256":digest(source.as_bytes()),"verified":true,"evidence":evidence})),
                Err(diagnostic)=>{
                    failures.push(format!("seed{index} {} O{optimization}D{debug}: {diagnostic}",toolset.profile));
                    results.push(json!({"case_id":format!("legacy-{index:03}/{}/O{optimization}D{debug}",toolset.profile),"family":generator::FAMILIES[index%generator::FAMILIES.len()],"generator_seed":index,"profile":toolset.profile,"optimization":optimization,"debug":debug,"verified":false,"diagnostic":diagnostic}));
                }
            }
                }
            }
        }
    }
    assert_eq!(
        results.len(),
        generator::PROGRAMS * 2 * 2 * 2,
        "legacy source identities/settings coverage shrank"
    );
    let report = json!({"schema":2,"oracle_protocol":support::oracle::PROTOCOL,"generator":"xorshift64/8boundedgrammarfamilies","required_families":generator::FAMILIES,"legacy_source_identities_preserved":legacy_preservation["preserved"],"legacy_source_preservation_evidence":legacy_preservation,"debug_levels":[0,2],"debug_independent_of_source_family_and_seed":true,"optimization_levels":[0,2],"formats":[6,14],"program_count":generator::PROGRAMS,"compiled_cases":results.len(),"runtime_inputs":input_sets,"typed_comparisons":(results.len()-failures.len())*3,"failed_cases":failures.len(),"failures":failures,"results":results});
    fs::create_dir_all(root.join("docs/results")).unwrap();
    fs::write(
        root.join("docs/results/generated-programs.json"),
        serde_json::to_vec_pretty(&report).unwrap(),
    )
    .unwrap();
    assert!(
        failures.is_empty(),
        "{} generated cases failed; first {:?}",
        failures.len(),
        &failures[..failures.len().min(5)]
    );
}

#[test]
#[ignore = "requires pinned v6/v14 compilers and typed VMs; mandatory v0.3 orthogonal/compositional gate"]
fn orthogonal_compositional_and_stateful_programs_behavior() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let artifacts = root.join("artifacts/generated-programs-v3");
    fs::create_dir_all(&artifacts).unwrap();
    let input_sets = inputs();
    let tools = [Toolset::checked(root, 6), Toolset::checked(root, 14)];
    let mut programs = Vec::new();
    for (family, name) in generator::FAMILIES.iter().enumerate() {
        for seed in [41, 73] {
            programs.push((
                format!("family-{name}-seed-{seed}"),
                (*name).to_owned(),
                seed,
                generator::program_from_axes(family, seed),
                false,
            ));
        }
    }
    for seed in [5, 41, 99, 107] {
        programs.push((
            format!("composition-seed-{seed}"),
            "compositional_stateful".into(),
            seed,
            generator::compositional_stateful_program(seed),
            true,
        ));
    }
    assert_eq!(programs.len(), 20);
    let required_source_ids: Vec<_> = programs.iter().map(|p| p.0.clone()).collect();
    let probe_source = artifacts.join("unchanged-stateful-probe.luau");
    fs::write(&probe_source,"local run=...\nlocal first=table.pack(run(2))\nprint('sequence first',first.n,table.unpack(first,1,first.n))\nlocal failed=table.pack(run(-3))\nprint('sequence error',failed.n,table.unpack(failed,1,failed.n))\nlocal final=table.pack(run(0))\nreturn final.n,table.unpack(final,1,final.n)\n").unwrap();
    let mut results = Vec::new();
    let mut failures = Vec::new();
    let mut required_case_ids = Vec::new();
    for toolset in &tools {
        let probe = toolset.compile(&probe_source, 0, 0).unwrap();
        let probes = vec![probe.clone(); input_sets.len()];
        for (source_id, family, seed, source, stateful) in &programs {
            let source_path = artifacts.join(format!("{source_id}.luau"));
            fs::write(&source_path, source).unwrap();
            for optimization in 0..=2 {
                for debug in [0, 2] {
                    let case_id =
                        format!("{source_id}/{}/O{optimization}D{debug}", toolset.profile);
                    required_case_ids.push(case_id.clone());
                    let directory = artifacts.join(&case_id);
                    let evidence = toolset.differential_with_probes(
                        &source_path,
                        &directory,
                        optimization,
                        debug,
                        &input_sets,
                        if *stateful { Some(&probes) } else { None },
                    );
                    match evidence {
                    Ok(evidence)=>results.push(json!({"case_id":case_id,"source_id":source_id,"family":family,"generator_seed":seed,"stateful_calls_per_loaded_closure":if *stateful{3}else{0},"source_sha256":digest(source.as_bytes()),"probe_sha256":if *stateful{Some(digest(&probe))}else{None},"verified":true,"evidence":evidence})),
                    Err(diagnostic)=>{failures.push(format!("{case_id}: {diagnostic}"));results.push(json!({"case_id":case_id,"source_id":source_id,"family":family,"generator_seed":seed,"verified":false,"diagnostic":diagnostic}));}
                }
                }
            }
        }
    }
    assert_eq!(
        results.len(),
        240,
        "orthogonal feature/settings coverage shrank"
    );
    let report = json!({"schema":1,"oracle_protocol":support::oracle::PROTOCOL,"complete":failures.is_empty(),"required_families":generator::FAMILIES,"required_source_ids":required_source_ids,"required_case_ids":required_case_ids,"case_plan_sha256":digest(&serde_json::to_vec(&required_case_ids).unwrap()),"orthogonal_family_count":8,"independent_family_seeds":[41,73],"compositional_seeds":[5,41,99,107],"optimization_levels":[0,1,2],"debug_levels":[0,2],"formats":[6,14],"runtime_inputs":input_sets,"source_programs":20,"compiled_cases":results.len(),"typed_comparisons":(results.len()-failures.len())*3,"stateful_programs":4,"calls_per_loaded_closure_sequence":3,"stateful_sequence_observations":4*2*3*2*3,"failed_cases":failures.len(),"failures":failures,"results":results});
    fs::write(
        root.join("docs/results/generated-programs-v3.json"),
        serde_json::to_vec_pretty(&report).unwrap(),
    )
    .unwrap();
    assert!(
        failures.is_empty(),
        "{} v3 generated cases failed; first {:?}",
        failures.len(),
        &failures[..failures.len().min(5)]
    );
}

#[test]
#[ignore = "manual bounded delta minimizer; scripts/minimize-generated.ps1 supplies explicit source"]
fn minimize_generated_failure() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let input = std::env::var_os("LUAU_MINIMIZE_SOURCE")
        .expect("use scripts/minimize-generated.ps1 -Source");
    let version: u8 = std::env::var("LUAU_MINIMIZE_VERSION")
        .unwrap_or_else(|_| "14".into())
        .parse()
        .unwrap();
    let optimization: usize = std::env::var("LUAU_MINIMIZE_OPTIMIZATION")
        .unwrap_or_else(|_| "2".into())
        .parse()
        .unwrap();
    let tools = Toolset::checked(root, version);
    let directory = root.join("artifacts/minimization");
    fs::create_dir_all(&directory).unwrap();
    let original = fs::read_to_string(input).unwrap();
    let candidate = directory.join("candidate.luau");
    let inputs = inputs();
    let mut checks = 0usize;
    let mut failure = |source: &str| -> Option<String> {
        checks += 1;
        fs::write(&candidate, source).unwrap();
        let Ok(bytecode) = tools.compile(&candidate, optimization, 2) else {
            return None;
        };
        for arguments in &inputs {
            let Ok(observation) =
                tools.observe(&bytecode, &directory, "candidate-original", arguments)
            else {
                return None;
            };
            if !observation.verified() || observation.outcome != support::oracle::Outcome::Return {
                return None;
            }
        }
        tools
            .differential(
                &candidate,
                &directory.join("check"),
                optimization,
                2,
                &inputs,
            )
            .err()
    };
    let first = failure(&original)
        .expect("the supplied valid source does not reproduce a decompiler/behavioral failure");
    let mut lines: Vec<_> = original.lines().map(String::from).collect();
    let mut granularity = 2usize;
    let mut diagnostic = first;
    let mut attempts = 0usize;
    while lines.len() > 1 && attempts < 96 {
        let width = lines.len().div_ceil(granularity);
        let mut reduced = false;
        for start in (0..lines.len()).step_by(width) {
            if attempts >= 96 {
                break;
            }
            attempts += 1;
            let end = (start + width).min(lines.len());
            let retained: Vec<_> = lines[..start]
                .iter()
                .chain(&lines[end..])
                .cloned()
                .collect();
            let source = retained.join("\n") + "\n";
            if let Some(error) = failure(&source) {
                lines = retained;
                diagnostic = error;
                granularity = 2;
                reduced = true;
                break;
            }
        }
        if !reduced {
            if granularity >= lines.len() {
                break;
            }
            granularity = (granularity * 2).min(lines.len());
        }
    }
    let minimized = lines.join("\n") + "\n";
    fs::write(directory.join("minimized.luau"), &minimized).unwrap();
    fs::write(directory.join("report.json"),serde_json::to_vec_pretty(&json!({"original_bytes":original.len(),"minimized_bytes":minimized.len(),"predicate_checks":checks,"deletion_attempts":attempts,"profile":tools.profile,"optimization":optimization,"valid_original_and_complete_inputs_required":true,"diagnostic":diagnostic})).unwrap()).unwrap();
    eprintln!(
        "minimized {} bytes to {} bytes in {checks} checks: {}",
        original.len(),
        minimized.len(),
        directory.join("minimized.luau").display()
    );
}
