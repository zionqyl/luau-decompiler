use luau_decompiler::{bytecode, Config};

fn varint(mut value: u32, bytes: &mut Vec<u8>) {
    loop {
        let mut part = (value & 127) as u8;
        value >>= 7;
        if value != 0 {
            part |= 128;
        }
        bytes.push(part);
        if value == 0 {
            return;
        }
    }
}

fn packet(version: u8, body: &[u8]) -> Vec<u8> {
    let mut bytes = vec![version];
    if version >= 4 {
        bytes.push(3);
    }
    bytes.push(0);
    if version >= 4 {
        bytes.push(0);
    }
    bytes.push(1);
    if version >= 12 {
        varint(body.len() as u32, &mut bytes);
    }
    bytes.extend_from_slice(body);
    bytes.push(0);
    bytes
}

fn simple(version: u8, instruction: u32) -> Vec<u8> {
    let mut body = vec![1, 0, 0, 0];
    if version >= 4 {
        body.extend_from_slice(&[0, 0]);
    }
    body.push(1);
    body.extend_from_slice(&instruction.to_le_bytes());
    body.extend_from_slice(&[0, 0, 0, 0, 0, 0]);
    if version >= 11 {
        body.push(0);
    }
    packet(version, &body)
}

#[test]
fn every_profile_decodes_its_own_empty_function_layout() {
    for version in 3..=14 {
        let bytes = simple(version, bytecode::Opcode::Return as u32 | (1 << 16));
        let module = bytecode::decode(&bytes, &Config::default().limits).unwrap();
        assert_eq!(module.version, version);
    }
}

#[test]
fn profile_selection_and_encoding_are_explicit() {
    let bytes = simple(14, bytecode::Opcode::Return as u32 | (1 << 16));
    let limits = Config::default().limits;
    assert!(
        bytecode::decode_with_options(&bytes, &limits, "luau-v13", "upstream")
            .unwrap_err()
            .message
            .contains("requires bytecode version 13")
    );
    assert!(bytecode::decode_with_options(&bytes, &limits, "auto", "guessed").is_err());
    let mut encoded = bytes.clone();

    let header_offset = 13;
    assert_eq!(encoded[header_offset], bytecode::Opcode::Return as u8);
    encoded[header_offset] = encoded[header_offset].wrapping_mul(227);
    let decoded =
        bytecode::decode_with_options(&encoded, &limits, "luau-v14", "roblox_opcode227").unwrap();
    assert_eq!(decoded.protos[0].code[0].op, bytecode::Opcode::Return);
    assert!(bytecode::decode(&encoded, &limits).is_err());
}

fn signature_container(mut bytes: Vec<u8>, code_offset: usize) -> Vec<u8> {
    bytes[code_offset] = bytes[code_offset].wrapping_mul(227);
    let signature = [
        0x11u8, 0x32, 0x53, 0x74, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16,
    ];
    bytes.extend_from_slice(&signature);
    let word = u32::from_le_bytes(signature[..4].try_into().unwrap());
    bytes.extend_from_slice(&(word ^ 0x7417_1870).to_le_bytes());
    bytes.extend_from_slice(&(word ^ 0x016a_c432).to_le_bytes());
    bytes
}

#[test]
fn observed_signed_container_requires_markers_version_and_exact_main_boundary() {
    let limits = Config::default().limits;
    for version in [9, 14] {
        let code_offset = if version >= 12 { 13 } else { 12 };
        let raw = simple(version, bytecode::Opcode::Return as u32 | (1 << 16));
        let container = signature_container(raw.clone(), code_offset);
        assert_eq!(
            bytecode::detected_encoding(&container),
            bytecode::ROBLOX_SIGNATURE_PROFILE
        );
        let module = bytecode::decode_with_options(&container, &limits, "auto", "auto").unwrap();
        assert_eq!(module.version, version);
        assert_eq!(module.protos[0].code[0].op, bytecode::Opcode::Return);
        assert!(
            bytecode::decode_with_options(&container, &limits, "auto", "roblox_opcode227").is_ok()
        );
        let mut arbitrary_trailer = container.clone();
        arbitrary_trailer[raw.len() + 16] ^= 1;
        assert!(bytecode::decode_with_options(
            &arbitrary_trailer,
            &limits,
            "auto",
            "roblox_opcode227"
        )
        .unwrap_err()
        .message
        .contains("24 trailing bytes"));
        let provenance = bytecode::representation(&container, "auto").unwrap();
        assert_eq!(provenance.body_bytes, raw.len());
        assert_eq!(provenance.trailer, container[raw.len()..]);
        assert!(provenance.authenticity.starts_with("not_verified"));
        for offset in [16, 20] {
            let mut bad = container.clone();
            let index = bad.len() - 24 + offset;
            bad[index] ^= 1;
            let error = bytecode::decode_with_options(
                &bad,
                &limits,
                "auto",
                bytecode::ROBLOX_SIGNATURE_PROFILE,
            )
            .unwrap_err();
            assert_eq!(error.stage, "representation");
            assert!(bytecode::decode_with_options(&bad, &limits, "auto", "auto").is_err());
        }
        let mut extra = container.clone();
        extra.insert(raw.len(), 0);
        assert!(
            bytecode::decode_with_options(&extra, &limits, "auto", "auto")
                .unwrap_err()
                .message
                .contains("exactly 24")
        );
        for count in [1, 8, 24] {
            assert!(bytecode::decode_with_options(
                &container[..container.len() - count],
                &limits,
                "auto",
                bytecode::ROBLOX_SIGNATURE_PROFILE
            )
            .is_err());
        }
        let mut bad_body = container.clone();
        bad_body[code_offset] = 255;
        assert!(bytecode::decode_with_options(&bad_body, &limits, "auto", "auto").is_err());
        let tight = luau_decompiler::Limits {
            max_bytes: raw.len(),
            ..limits.clone()
        };
        assert!(bytecode::decode_with_options(&container, &tight, "auto", "auto").is_err());
        let mut changed_signature = container.clone();
        changed_signature[raw.len() + 4] ^= 1;
        let provenance = bytecode::representation(&changed_signature, "auto").unwrap();
        assert_ne!(provenance.trailer, container[raw.len()..]);
        assert!(provenance.authenticity.starts_with("not_verified"));
    }
    let older = signature_container(simple(6, bytecode::Opcode::Return as u32 | (1 << 16)), 12);
    assert_eq!(bytecode::detected_encoding(&older), "upstream");
    assert!(bytecode::decode_with_options(
        &older,
        &limits,
        "auto",
        bytecode::ROBLOX_SIGNATURE_PROFILE
    )
    .is_err());
}

#[test]
fn version_twelve_requires_exact_prototype_boundaries() {
    let mut bytes = simple(12, bytecode::Opcode::Return as u32 | (1 << 16));

    bytes[5] -= 1;
    let error = bytecode::decode(&bytes, &Config::default().limits).unwrap_err();
    assert_eq!(error.proto, Some(0));
    assert!(error.message.contains("truncated") || error.message.contains("prototype size"));
    bytes[5] += 2;
    let error = bytecode::decode(&bytes, &Config::default().limits).unwrap_err();
    assert!(error.message.contains("prototype size"));
}

fn with_constants(version: u8, constants: &[u8]) -> Vec<u8> {
    let mut body = vec![1, 0, 0, 0, 0, 0, 1];
    body.extend_from_slice(&(bytecode::Opcode::Return as u32 | (1 << 16)).to_le_bytes());
    body.extend_from_slice(constants);
    body.extend_from_slice(&[0, 0, 0, 0, 0]);
    if version >= 11 {
        body.push(0);
    }
    packet(version, &body)
}

#[test]
fn constant_tags_are_version_specific_and_values_remain_typed() {
    let limits = Config::default().limits;

    let constants = [2, 1, 1, 8, 1, 0, 255, 255, 255, 255];
    assert!(bytecode::decode(&with_constants(6, &constants), &limits).is_err());
    let module = bytecode::decode(&with_constants(7, &constants), &limits).unwrap();
    assert_eq!(
        module.protos[0].constants[1],
        bytecode::Constant::TableWithConstants(vec![(0, None)])
    );
    let mut vector = vec![1, 11];
    for value in [1.0000000000000002f64, -0.0, 2.5, 0.0] {
        vector.extend_from_slice(&value.to_le_bytes());
    }
    assert!(bytecode::decode(&with_constants(12, &vector), &limits).is_err());
    let module = bytecode::decode(&with_constants(13, &vector), &limits).unwrap();
    let bytecode::Constant::VectorDouble(parts) = &module.protos[0].constants[0] else {
        panic!("double vector tag was narrowed");
    };
    assert_eq!(parts[0].to_bits(), 1.0000000000000002f64.to_bits());
    assert_eq!(parts[1].to_bits(), (-0.0f64).to_bits());
    for (version, tag, diagnostic) in [(8, 9, "INTEGER"), (10, 10, "CLASS_SHAPE")] {
        let error = bytecode::decode(&with_constants(version, &[1, tag]), &limits).unwrap_err();
        assert!(error.message.contains(diagnostic), "{error}");
    }
}

#[test]
fn roblox_encoding_never_transforms_aux_words() {
    let mut body = vec![1, 0, 0, 0, 0, 0, 3];
    body.extend_from_slice(&(bytecode::Opcode::NewTable as u32).to_le_bytes());
    body.extend_from_slice(&227u32.to_le_bytes());
    body.extend_from_slice(&(bytecode::Opcode::Return as u32 | (1 << 16)).to_le_bytes());
    body.extend_from_slice(&[0, 0, 0, 0, 0, 0, 0]);
    let mut bytes = packet(14, &body);
    bytes[13] = bytes[13].wrapping_mul(227);
    bytes[21] = bytes[21].wrapping_mul(227);
    let module = bytecode::decode_with_options(
        &bytes,
        &Config::default().limits,
        "auto",
        "roblox_opcode227",
    )
    .unwrap();
    assert_eq!(module.protos[0].code[0].aux, Some(227));
}

#[test]
fn call_feedback_is_validated_before_normalizing_its_call_semantics() {
    let mut body = vec![1, 0, 0, 0, 0, 0, 4];
    body.extend_from_slice(&(bytecode::Opcode::LoadNil as u32).to_le_bytes());
    body.extend_from_slice(&(87u32 | (1 << 16) | (1 << 24)).to_le_bytes());
    body.extend_from_slice(&0u32.to_le_bytes());
    body.extend_from_slice(&(bytecode::Opcode::Return as u32 | (1 << 16)).to_le_bytes());
    body.extend_from_slice(&[0, 0, 0, 0, 0, 0, 1, 0, 1]);
    let limits = Config::default().limits;
    let module = bytecode::decode(&packet(11, &body), &limits).unwrap();
    assert_eq!(module.protos[0].code[1].op, bytecode::Opcode::Call);
    assert_eq!(module.protos[0].code[1].pc, 1);
    assert_eq!(module.protos[0].code[1].len(), 2);
    *body.last_mut().unwrap() = 3;
    let error = bytecode::decode(&packet(11, &body), &limits).unwrap_err();
    assert!(error.message.contains("not CALLFB"));
    *body.last_mut().unwrap() = 1;
    let kind = body.len() - 2;
    body[kind] = 255;
    assert!(bytecode::decode(&packet(11, &body), &limits)
        .unwrap_err()
        .message
        .contains("feedback slot kind"));
}

#[test]
fn new_instruction_families_are_diagnosed_instead_of_omitted() {
    for (version, opcode, name) in [
        (9, 83, "GETUDATAKS"),
        (10, 86, "NEWCLASSMEMBER"),
        (11, 88, "CMPPROTO"),
    ] {
        let bytes = simple(version, opcode);
        let error = bytecode::decode(&bytes, &Config::default().limits).unwrap_err();
        assert!(error.message.contains(name), "{error}");
        assert_eq!(error.proto, Some(0));
        assert_eq!(error.pc, Some(0));
    }
}

#[test]
fn malformed_fastpcall_is_validated_before_lowering() {
    let error = bytecode::decode(&simple(14, 89), &Config::default().limits).unwrap_err();
    assert_eq!(error.stage, "validate");
    assert!(error.message.contains("jump target"), "{error}");
    assert_eq!(error.proto, Some(0));
    assert_eq!(error.pc, Some(0));
}

#[test]
fn all_compiler_profile_fixtures_decode() {
    let root = std::path::Path::new(env!("CARGO_MANIFEST_DIR")).join("tests/profile-fixtures");
    let manifest: serde_json::Value =
        serde_json::from_slice(&std::fs::read(root.join("manifest.json")).unwrap()).unwrap();
    let mut failures = Vec::new();
    for fixture in manifest["fixtures"].as_array().unwrap() {
        let name = fixture["bytecode"].as_str().unwrap();
        let bytes = std::fs::read(root.join(name)).unwrap();
        if let Err(error) = bytecode::decode(&bytes, &Config::default().limits) {
            failures.push(format!("{name}: {error}"));
        }
    }
    assert!(
        failures.is_empty(),
        "{} decode failures: {:?}",
        failures.len(),
        &failures[..failures.len().min(15)]
    );
}

#[test]
fn bounded_modern_mutations_never_panic() {
    let root = std::path::Path::new(env!("CARGO_MANIFEST_DIR")).join("tests/profile-fixtures");
    let manifest: serde_json::Value =
        serde_json::from_slice(&std::fs::read(root.join("manifest.json")).unwrap()).unwrap();
    let limits = luau_decompiler::config::Limits {
        max_protos: 256,
        max_instructions: 20_000,
        max_constants: 20_000,
        max_string_bytes: 512 * 1024,
        ..Default::default()
    };
    let mut state = 0xf47a_3021_792e_d083u64;
    let mut mutations = 0;
    for fixture in manifest["fixtures"].as_array().unwrap() {
        let bytes = std::fs::read(root.join(fixture["bytecode"].as_str().unwrap())).unwrap();
        for _ in 0..16 {
            state ^= state << 13;
            state ^= state >> 7;
            state ^= state << 17;
            let mut mutated = bytes.clone();
            let offset = (state as usize) % mutated.len();
            mutated[offset] ^= (state >> 32) as u8 | 1;
            let _ = bytecode::decode(&mutated, &limits);
            mutations += 1;
        }
    }
    assert!(mutations >= 29_952);
}

fn madium_probe() -> Vec<u8> {
    let hex = "0e0300000128010000010a0004a3000000ff0000000000000082000200000001000118000000000100000000000a00";
    hex.as_bytes()
        .chunks_exact(2)
        .map(|part| u8::from_str_radix(std::str::from_utf8(part).unwrap(), 16).unwrap())
        .collect()
}

#[test]
fn madium_native_probe_requires_the_explicit_roblox_encoding() {
    let bytes = madium_probe();
    let limits = Config::default().limits;
    assert!(bytecode::decode(&bytes, &limits).is_err());
    let module =
        bytecode::decode_with_options(&bytes, &limits, "luau-v14", "roblox_opcode227").unwrap();
    let proto = &module.protos[module.main];
    assert!(proto.constants.is_empty());
    assert!(proto.children.is_empty());
    assert_eq!(
        proto
            .code
            .iter()
            .map(|instruction| instruction.op)
            .collect::<Vec<_>>(),
        [
            bytecode::Opcode::PrepVarargs,
            bytecode::Opcode::NewTable,
            bytecode::Opcode::Return
        ]
    );
    assert_eq!(proto.code[2].a(), 0);
    assert_eq!(proto.code[2].b(), 2);
}

#[test]
#[ignore = "requires pinned official 0.746 compiler; source of native probe remains unknown"]
fn native_probe_matches_independent_compiler_model() {
    let root = std::path::Path::new(env!("CARGO_MANIFEST_DIR"));
    let artifacts = root.join("artifacts/native-probe");
    std::fs::create_dir_all(&artifacts).unwrap();
    let source = artifacts.join("return-empty-table.luau");
    std::fs::write(&source, b"return {}\n").unwrap();
    let compiler = root.join(format!(
        ".tools/luau-modern/luau-compile{}",
        std::env::consts::EXE_SUFFIX
    ));
    let limits = Config::default().limits;
    let native =
        bytecode::decode_with_options(&madium_probe(), &limits, "luau-v14", "roblox_opcode227")
            .unwrap();
    let native = &native.protos[native.main];
    let mut normalized_probe = madium_probe();
    for instruction in &native.code {
        let offset = 13 + instruction.pc * 4;
        normalized_probe[offset] = normalized_probe[offset].wrapping_mul(203);
    }
    let mut matches = 0;
    let mut identical_packets = 0;
    let mut evidence = Vec::new();
    for optimization in 0..=2 {
        for debug in 0..=2 {
            let compiled = std::process::Command::new(&compiler)
                .arg("--binary")
                .arg(format!("-O{optimization}"))
                .arg(format!("-g{debug}"))
                .arg("--fflags=LuauCompileFastpcall=true,DebugLuauUserDefinedClasses=false")
                .arg(&source)
                .output()
                .unwrap();
            assert!(compiled.status.success());
            let module = bytecode::decode(&compiled.stdout, &limits).unwrap();
            let model = &module.protos[module.main];
            let packet_identical = normalized_probe == compiled.stdout;
            if packet_identical {
                identical_packets += 1;
            }
            assert_eq!(native.max_stack, model.max_stack);
            assert_eq!(native.num_params, model.num_params);
            assert_eq!(native.num_upvalues, model.num_upvalues);
            assert_eq!(native.is_vararg, model.is_vararg);
            assert_eq!(native.constants, model.constants);
            assert_eq!(native.children, model.children);
            assert_eq!(
                native
                    .code
                    .iter()
                    .map(|i| (i.word & !255, i.op, i.aux))
                    .collect::<Vec<_>>(),
                model
                    .code
                    .iter()
                    .map(|i| (i.word & !255, i.op, i.aux))
                    .collect::<Vec<_>>()
            );
            eprintln!("probe compiler model O{optimization}D{debug}: complete normalized packet identical={packet_identical}; flags native={} compiler={}, line native={} compiler={}, debug locals native={} compiler={}", native.flags, model.flags, native.line_defined, model.line_defined,native.locals.len(),model.locals.len());
            evidence.push(serde_json::json!({"optimization":optimization,"debug":debug,"semantic_fields_equal":true,"complete_normalized_packet_equal":packet_identical,"probe_bytes":normalized_probe.len(),"compiler_bytes":compiled.stdout.len(),"flags_equal":native.flags==model.flags,"line_defined_equal":native.line_defined==model.line_defined,"locals_equal":native.locals.len()==model.locals.len()}));
            matches += 1;
        }
    }
    assert_eq!(matches, 9);
    assert!(
        identical_packets > 0,
        "no independent compiler setting reproduces the complete normalized native packet"
    );
    std::fs::create_dir_all(root.join("docs/results")).unwrap();
    std::fs::write(root.join("docs/results/native-probe-model.json"), serde_json::to_vec_pretty(&serde_json::json!({"upstream_revision":luau_decompiler::profiles::MODERN_REVISION,"normalizer":"roblox_opcode227","original_source_provenance":"unknown","independent_source":"return {}\n","semantic_matches":matches,"complete_packet_matches":identical_packets,"cases":evidence})).unwrap()).unwrap();
}
