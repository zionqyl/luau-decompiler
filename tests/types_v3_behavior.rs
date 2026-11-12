mod support;
use luau_decompiler::{decompile, Config};
use serde_json::{json, Value};
use std::{fs, path::Path, process::Command};

fn compile(
    tools: &support::Toolset,
    path: &Path,
    o: usize,
    d: usize,
    t: usize,
) -> Result<Vec<u8>, String> {
    let mut command = Command::new(&tools.compiler);
    command
        .arg("--binary")
        .arg(format!("-O{o}"))
        .arg(format!("-g{d}"))
        .arg(format!("-t{t}"));
    if !tools.flags.is_empty() {
        command.arg(format!("--fflags={}", tools.flags));
    }
    let out = command.arg(path).output().map_err(|e| e.to_string())?;
    if !out.status.success() || out.stdout.first() == Some(&0) {
        return Err(format!(
            "compiler: {}",
            String::from_utf8_lossy(&out.stderr)
        ));
    }
    Ok(out.stdout)
}

#[test]
#[ignore = "requires pinned v6/v14 compilers and typed VMs; mandatory v0.3 annotation/format semantic gate"]
fn typed_output_matrix_preserves_behavior() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let destination = root.join("artifacts/types-v3");
    fs::create_dir_all(&destination).unwrap();
    let families = [
        "scalar_parameters",
        "generic_identity",
        "callbacks",
        "optional_joins",
        "aliases_mutation",
        "assertion_multret",
        "stateful_captures",
        "generic_record",
        "generic_vararg",
    ];
    let mut rows = Vec::new();
    let mut failures = Vec::new();
    let mut comparisons = 0usize;
    for version in [6, 14] {
        let tools = support::Toolset::checked(root, version);
        for family in families {
            let source = root.join(format!("tests/type-corpus/{family}.luau"));
            let source_hash = support::digest(&fs::read(&source).unwrap());
            for o in [0, 2] {
                for d in [0, 2] {
                    for t in [0, 1] {
                        let identity = format!("{family}/v{version}/O{o}/D{d}/T{t}");
                        let dir = destination.join(identity.replace('/', "-"));
                        fs::create_dir_all(&dir).unwrap();
                        let result = (|| -> Result<Value, String> {
                            let original = compile(&tools, &source, o, d, t)?;
                            let module =
                                luau_decompiler::bytecode::decode(&original, &Default::default())
                                    .map_err(|e| e.to_string())?;
                            if t == 1
                                && !module
                                    .protos
                                    .iter()
                                    .any(|p| !p.type_metadata.raw_bytes.is_empty())
                            {
                                return Err("type-enabled fixture contains no metadata".into());
                            }
                            let mut config = Config::default();
                            config.validation.mode = luau_decompiler::quality::ValidationMode::Off;
                            config.formatting.line_width = 60;
                            let result =
                                decompile(&original, &config).map_err(|e| e.to_string())?;
                            if !result.complete {
                                return Err("incomplete reconstruction".into());
                            }
                            if result.source.contains(":: any") {
                                return Err("invented permissive cast".into());
                            }
                            let recovered = dir.join("recovered.luau");
                            fs::write(&recovered, &result.source).map_err(|e| e.to_string())?;
                            let rebuilt = compile(&tools, &recovered, o, d, 0)?;
                            let mut inputs = Vec::new();
                            for seed in [-3f64, 0.0, 7.0] {
                                let arguments =
                                    vec![support::oracle::Value::Number(seed.to_bits())];
                                let probe_path = if family == "stateful_captures" {
                                    let text=format!("local f=...\nlocal a=table.pack(f({seed}))\nlocal b=table.pack(f(0))\nlocal c=table.pack(f({seed}))\nreturn a.n,a[1],a[2],b.n,b[1],b[2],c.n,c[1],c[2]\n");
                                    let p = dir.join(format!("probe-{seed}.luau"));
                                    fs::write(&p, text).map_err(|e| e.to_string())?;
                                    let bytes = compile(&tools, &p, 0, 0, 0)?;
                                    let p = dir.join(format!("probe-{seed}.bc"));
                                    fs::write(&p, bytes).map_err(|e| e.to_string())?;
                                    Some(p)
                                } else {
                                    None
                                };
                                let expected = tools.observe_with_probe(
                                    &original,
                                    &dir,
                                    &format!("original-{seed}"),
                                    &arguments,
                                    probe_path.as_deref(),
                                )?;
                                let actual = tools.observe_with_probe(
                                    &rebuilt,
                                    &dir,
                                    &format!("rebuilt-{seed}"),
                                    &arguments,
                                    probe_path.as_deref(),
                                )?;
                                if !expected.equivalent(&actual) {
                                    return Err(format!("typed observation differs seed={seed}: {expected:?} vs {actual:?}"));
                                }
                                comparisons += 1;
                                inputs.push(json!({"seed":seed,"expected":expected,"actual":actual,"verified":true}));
                            }
                            Ok(
                                json!({"original_sha256":support::digest(&original),"source_sha256":source_hash,"recovered_source_sha256":support::digest(result.source.as_bytes()),"rebuilt_sha256":support::digest(&rebuilt),"type_report":result.type_report,"original_type_metadata":module.protos.iter().map(|p|&p.type_metadata).collect::<Vec<_>>(),"inputs":inputs,"complete":true}),
                            )
                        })();
                        match result{Ok(evidence)=>rows.push(json!({"id":identity,"family":family,"version":version,"optimization":o,"debug":d,"type_information":t,"verified":true,"evidence":evidence})),Err(error)=>{failures.push(format!("{identity}: {error}"));rows.push(json!({"id":identity,"verified":false,"diagnostic":error}));}}
                    }
                }
            }
        }
    }
    let report = json!({"schema":1,"oracle_protocol":"LOBS/1","families":families,"versions":[6,14],"optimizations":[0,2],"debug_levels":[0,2],"type_information_levels":[0,1],"runtime_seeds":[-3,0,7],"compiled_cases":rows.len(),"required_cases":144,"typed_comparisons":comparisons,"required_comparisons":432,"failed_cases":failures.len(),"failures":failures,"results":rows});
    fs::create_dir_all(root.join("docs/results")).unwrap();
    fs::write(
        root.join("docs/results/types-v3-behavior.json"),
        serde_json::to_vec_pretty(&report).unwrap(),
    )
    .unwrap();
    assert_eq!(rows.len(), 144);
    assert!(
        failures.is_empty(),
        "{} failures: {}",
        failures.len(),
        failures.join("\n")
    );
    assert_eq!(comparisons, 432);
}

#[test]
#[ignore = "requires pinned compiler and independent Roblox-aware analyzer; mandatory typed presentation quality gate"]
fn real_compiler_typed_presentations_are_independently_analyzed() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let dir = root.join("artifacts/types-v3-quality");
    fs::create_dir_all(&dir).unwrap();
    let tools = support::Toolset::checked(root, 14);
    let mut rows = Vec::new();
    for family in [
        "scalar_parameters",
        "generic_identity",
        "generic_record",
        "generic_vararg",
        "roblox_identity",
        "roblox_position",
        "roblox_snapshot",
    ] {
        let source = root.join(format!("tests/type-corpus/{family}.luau"));
        let bytes = compile(&tools, &source, 2, 2, 1).unwrap();
        let mut config = Config::default();
        config.validation.mode = luau_decompiler::quality::ValidationMode::Off;
        if family.starts_with("roblox_") {
            let plain = decompile(&bytes, &config).unwrap();
            let player=plain.bindings.iter().find(|b|b.parameter&&b.debug_name.as_deref()==Some("player")).expect("debug metadata identifies the supplied known-source parameter; spelling does not infer its class");
            config
                .typing
                .binding_types
                .insert(format!("p{}:b{}", player.proto, player.id), "Player".into());
            config.naming = luau_decompiler::NameStyle::CamelCase;
        }
        config.validation.mode = luau_decompiler::quality::ValidationMode::StrictRequired;
        let result = decompile(&bytes, &config).unwrap();
        let recovered = dir.join(format!("{family}.luau"));
        fs::write(&recovered, &result.source).unwrap();
        rows.push(json!({"family":family,"input_sha256":support::digest(&bytes),"source_sha256":support::digest(result.source.as_bytes()),"type_report":result.type_report,"validation":result.validation,"behavioral_status":if family.starts_with("roblox_"){"not_run; engine Player contract, no fake runtime"}else{"separate typed differential matrix"}}));
    }
    let strict_passed = rows
        .iter()
        .filter(|row| row["validation"]["strict_analysis"] == "passed")
        .count();
    let strict_failed = rows
        .iter()
        .filter(|row| row["validation"]["strict_analysis"] == "failed")
        .count();
    let report = json!({"schema":2,"cases":rows.len(),"required_positive_families":["scalar_parameters","generic_identity","generic_record","generic_vararg","roblox_identity","roblox_position","roblox_snapshot"],"strict_passed":strict_passed,"strict_failed":strict_failed,"snapshot_constructor_repaired":true,"results":rows});
    fs::write(
        root.join("docs/results/types-v3-quality.json"),
        serde_json::to_vec_pretty(&report).unwrap(),
    )
    .unwrap();
    for row in report["results"].as_array().unwrap() {
        assert_eq!(row["validation"]["syntax"], "passed", "{row}");
        assert_eq!(row["validation"]["compilation"], "passed", "{row}");
    }
    for row in report["results"].as_array().unwrap() {
        assert_eq!(row["validation"]["strict_analysis"], "passed", "{row}");
        assert_eq!(row["validation"]["required_passed"], true, "{row}");
        assert!(row["type_report"]["emitted_useful_annotations"].as_u64().unwrap_or(0)>0,"Every positive family must retain useful typing, not silently shrink to one passing case: {row}");
    }
}
