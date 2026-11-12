use luau_decompiler::quality::ValidationMode;
use luau_decompiler::{attribution, process, Config, InputFormat, OutputPolicy};
use sha2::{Digest, Sha256};

#[test]
fn source_bytecode_and_policy_candidates_finalize_without_optional_branding() {
    for policy in [
        OutputPolicy::Faithful,
        OutputPolicy::Annotated,
        OutputPolicy::VerifiedTyped,
    ] {
        for (input, format) in [
            (
                b"local answer=42 return answer".as_slice(),
                InputFormat::LuauSource,
            ),
            (
                include_bytes!("fixtures/arithmetic.O1.D2.bc").as_slice(),
                InputFormat::LuauBytecode,
            ),
        ] {
            let mut config = Config {
                output_policy: policy,
                ..Config::default()
            };
            config.validation.mode = ValidationMode::Off;
            if policy == OutputPolicy::VerifiedTyped {
                assert!(process(input, format, &config).is_err());
                continue;
            }
            let result = process(input, format, &config).unwrap();
            assert!(result.complete);
            assert_eq!(result.input_sha256, format!("{:x}", Sha256::digest(input)));
            assert!(result.source.contains(&attribution::block()));
            assert_eq!(result.source.matches(&attribution::block()).count(), 1);
            if result.source.starts_with("--!strict") {
                assert!(result.source.starts_with(&attribution::prefix(true)));
            }
            if let Some(baseline) = result.baseline_source {
                assert!(baseline.contains(&attribution::block()));
            }
            if policy == OutputPolicy::VerifiedTyped {
                assert!(!result.validation.required_passed);
            }
        }
    }
    assert!(process(b"\x1bLua\x54broken", InputFormat::Auto, &Config::default()).is_err());
}

#[test]
fn leading_official_blocks_update_once_without_touching_literals_or_notices() {
    let old="--[=[\n    Luau Decompiler 0.4.0-rc.2\n    Made by @zionqyl\n    https://github.com/zionqyl/luau-decompiler\n]=]";
    let body = format!("local text=[==[{old}]==]\nreturn text\n");
    let mut source = format!("--!strict\n{old}\n-- SPDX-License-Identifier: MIT\n{old}\n{body}");
    attribution::finalize(&mut source, &mut [], 8192).unwrap();
    assert!(source.starts_with(&attribution::prefix(true)));
    assert!(source.contains("-- SPDX-License-Identifier: MIT"));
    assert!(source.ends_with(&body));
    assert_eq!(source.matches(old).count(), 1);
    assert_eq!(source.matches(&attribution::block()).count(), 1);
    let once = source.clone();
    attribution::finalize(&mut source, &mut [], 8192).unwrap();
    assert_eq!(once, source);
}

#[test]
fn finalized_positions_limits_and_original_offsets_have_distinct_meanings() {
    let input = b"local originalName=1\nreturn originalName\n";
    let mut config = Config::default();
    config.validation.mode = ValidationMode::Off;
    let result = process(input, InputFormat::LuauSource, &config).unwrap();
    assert_eq!(result.source_bindings[0].declaration_start, 6);
    let mut raw = "local value=1\nreturn value\n".to_owned();
    let mut regions = vec![luau_decompiler::types::GeneratedRegion {
        first_line: 1,
        first_column: 1,
        last_line: 2,
        last_column: 8,
        ..Default::default()
    }];
    attribution::finalize(&mut raw, &mut regions, 4096).unwrap();
    assert_eq!(
        raw.lines().nth(regions[0].first_line - 1),
        Some("local value=1")
    );
    assert_eq!(
        raw.lines().nth(regions[0].last_line - 1),
        Some("return value")
    );
    assert!(attribution::finalize(&mut "return 1".to_owned(), &mut [], 32).is_err());
    let empty = process(b"", InputFormat::LuauSource, &config).unwrap();
    assert!(empty.source.ends_with("return\n"));
}

#[test]
#[ignore = "requires pinned analyzer and independent controlled VM"]
fn final_strict_source_and_empty_return_behavior_are_checked_independently() {
    let mut config = Config {
        output_policy: OutputPolicy::VerifiedTyped,
        ..Config::default()
    };
    let positive = process(
        b"local answer=42 return answer",
        InputFormat::LuauSource,
        &config,
    )
    .unwrap();
    assert!(
        positive.validation.required_passed,
        "{:?}",
        positive.validation
    );
    let final_hash = format!("{:x}", Sha256::digest(positive.source.as_bytes()));
    assert!(positive
        .validation
        .attempts
        .iter()
        .any(|a| a.source_sha256 == final_hash));
    let negative = process(
        b"local answer:number='wrong' return answer",
        InputFormat::LuauSource,
        &config,
    )
    .unwrap();
    assert!(!negative.validation.required_passed);
    assert!(negative.source.contains(&attribution::block()));
    assert!(negative
        .baseline_source
        .as_ref()
        .is_none_or(|s| s.contains(&attribution::block())));
    config.validation.mode = ValidationMode::Off;
    config.output_policy = OutputPolicy::Faithful;
    let root = std::path::Path::new(env!("CARGO_MANIFEST_DIR"));
    let directory = root.join("artifacts/attribution-rc3");
    std::fs::create_dir_all(&directory).unwrap();
    let tools = support::Toolset::checked(root, 14);
    let mut rows = Vec::new();
    for (id, original) in [
        ("empty_chunk", ""),
        ("header_text_literal", "return [==[Made by @zionqyl]==]"),
    ] {
        let output = process(original.as_bytes(), InputFormat::LuauSource, &config).unwrap();
        let before = directory.join("before.luau");
        let after = directory.join("after.luau");
        std::fs::write(&before, original).unwrap();
        std::fs::write(&after, &output.source).unwrap();
        let expected = tools
            .observe(
                &tools.compile(&before, 0, 0).unwrap(),
                &directory,
                "before",
                &[],
            )
            .unwrap();
        let actual = tools
            .observe(
                &tools.compile(&after, 0, 0).unwrap(),
                &directory,
                "after",
                &[],
            )
            .unwrap();
        assert!(expected.equivalent(&actual));
        rows.push(serde_json::json!({"id":id,"input_sha256":output.input_sha256,"source_sha256":support::digest(output.source.as_bytes()),"expected":expected,"actual":actual,"verified":true}));
    }
    std::fs::write(directory.join("report.json"),serde_json::to_vec_pretty(&serde_json::json!({"passed":true,"version":env!("CARGO_PKG_VERSION"),"positive_source_sha256":final_hash,"positive_validation":positive.validation,"negative_source_retained":negative.source.contains(&attribution::block()),"negative_validation":negative.validation,"compiler_sha256":tools.compiler_hash,"oracle_sha256":tools.runner_hash,"cases":rows})).unwrap()).unwrap();
}

mod support;
