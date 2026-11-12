use luau_decompiler::{
    bytecode::{self, Opcode},
    decompile, Config,
};
use serde_json::json;
use sha2::{Digest, Sha256};
use std::{fs, path::Path, process::Command};

const NATIVE_HEX:&str="0e0300000128010000010a0004a3000000ff0000000000000082000200000001000118005a00000100000000000a00";
const OLD_HEX:&str="0e0300000128010000010a0004a3000000ff0000000000000082000200000001000118000000000100000000000a00";
fn bytes(hex: &str) -> Vec<u8> {
    hex.as_bytes()
        .chunks_exact(2)
        .map(|part| u8::from_str_radix(std::str::from_utf8(part).unwrap(), 16).unwrap())
        .collect()
}
fn digest(bytes: &[u8]) -> String {
    format!("{:x}", Sha256::digest(bytes))
}

#[test]
fn current_native_packet_has_only_the_proven_effect_free_operations() {
    let packet = bytes(NATIVE_HEX);
    assert_eq!(packet.len(), 47);
    let mut config = Config {
        profile: "luau-v14".into(),
        bytecode_encoding: "roblox_opcode227".into(),
        ..Config::default()
    };
    config.typing.mode = luau_decompiler::types::TypingMode::Off;
    config.validation.mode = luau_decompiler::quality::ValidationMode::Off;
    assert!(bytecode::decode(&packet, &config.limits).is_err());
    let module = bytecode::decode_with_options(
        &packet,
        &config.limits,
        &config.profile,
        &config.bytecode_encoding,
    )
    .unwrap();
    assert_eq!(module.protos.len(), 1);
    assert_eq!(module.main, 0);
    assert!(module.strings.is_empty());
    let p = &module.protos[0];
    assert_eq!(
        (p.max_stack, p.num_params, p.num_upvalues, p.is_vararg),
        (1, 0, 0, true)
    );
    assert!(
        p.constants.is_empty()
            && p.children.is_empty()
            && p.locals.is_empty()
            && p.upvalue_names.is_empty()
    );
    assert_eq!(
        p.code
            .iter()
            .map(|i| (i.pc, i.op, i.a(), i.b(), i.c(), i.aux))
            .collect::<Vec<_>>(),
        [
            (0, Opcode::PrepVarargs, 0, 0, 0, None),
            (1, Opcode::NewTable, 0, 0, 0, Some(0)),
            (3, Opcode::Return, 0, 2, 0, None)
        ]
    );
    assert_eq!(
        decompile(&packet, &config).unwrap().source,
        format!(
            "{}return {{}}\n",
            luau_decompiler::attribution::prefix(false)
        )
    );
}

#[test]
#[ignore = "requires pinned official0.746 compiler; native original source remains unknown"]
fn current_native_packet_matches_padded_independent_compiler_model() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let artifacts = root.join("artifacts/native-v3-model");
    fs::create_dir_all(&artifacts).unwrap();
    let packet = bytes(NATIVE_HEX);
    let old = bytes(OLD_HEX);
    let limits = Config::default().limits;
    let module =
        bytecode::decode_with_options(&packet, &limits, "luau-v14", "roblox_opcode227").unwrap();
    let native = &module.protos[module.main];
    let differences:Vec<_>=packet.iter().zip(&old).enumerate().filter(|(_, (a,b))|a!=b).map(|(offset,(current,previous))|json!({"byte_offset":offset,"previous":previous,"current":current})).collect();
    assert_eq!(differences.len(), 1);
    assert_eq!(differences[0]["previous"], 0);
    assert_eq!(differences[0]["current"], 90);

    assert_eq!(&packet[..13], &[14, 3, 0, 0, 1, 40, 1, 0, 0, 1, 10, 0, 4]);
    let mut normalized = packet.clone();
    for instruction in &native.code {
        let offset = 13 + instruction.pc * 4;
        normalized[offset] = normalized[offset].wrapping_mul(203);
    }
    let normalized_module = bytecode::decode(&normalized, &limits).unwrap();
    assert_eq!(normalized_module.protos[0].code.len(), 3);
    fs::write(artifacts.join("native-roblox.bc"), &packet).unwrap();
    fs::write(artifacts.join("native-upstream.bc"), &normalized).unwrap();
    let source = format!("{}return {{}}\n", "\n".repeat(90));
    let source_path = artifacts.join("independent-return-table-line91.luau");
    fs::write(&source_path, &source).unwrap();
    let compiler = root.join(format!(
        ".tools/luau-modern/luau-compile{}",
        std::env::consts::EXE_SUFFIX
    ));
    let compiler_hash = digest(&fs::read(&compiler).unwrap());
    let lock: serde_json::Value =
        serde_json::from_slice(&fs::read(root.join("upstream.profiles.lock.json")).unwrap())
            .unwrap();
    let pinned = lock["profiles"]
        .as_array()
        .unwrap()
        .iter()
        .find(|p| p["tag"] == "0.746")
        .unwrap();
    assert_eq!(pinned["windows_compiler_sha256"], compiler_hash);
    assert_eq!(
        pinned["revision"],
        luau_decompiler::profiles::MODERN_REVISION
    );
    let mut evidence = Vec::new();
    let mut whole_matches = 0;
    for optimization in 0..=2 {
        for debug in 0..=2 {
            let compiled = Command::new(&compiler)
                .args([
                    "--binary",
                    &format!("-O{optimization}"),
                    &format!("-g{debug}"),
                    "--fflags=LuauCompileFastpcall=true,DebugLuauUserDefinedClasses=false",
                ])
                .arg(&source_path)
                .output()
                .unwrap();
            assert!(compiled.status.success(), "{:?}", compiled.stderr);
            let model = bytecode::decode(&compiled.stdout, &limits).unwrap();
            assert_eq!(model.protos.len(), 1);
            assert_eq!(model.main, 0);
            assert_eq!(module.strings, model.strings);
            assert_eq!(module.userdata_types, model.userdata_types);
            let p = &model.protos[0];
            assert_eq!(
                (
                    native.max_stack,
                    native.num_params,
                    native.num_upvalues,
                    native.is_vararg,
                    native.flags,
                    native.line_defined
                ),
                (
                    p.max_stack,
                    p.num_params,
                    p.num_upvalues,
                    p.is_vararg,
                    p.flags,
                    p.line_defined
                )
            );
            assert_eq!(native.constants, p.constants);
            assert_eq!(native.children, p.children);
            assert_eq!(native.debug_name, p.debug_name);
            assert_eq!(native.type_metadata.raw_bytes, p.type_metadata.raw_bytes);
            assert!(p.locals.is_empty() && p.upvalue_names.is_empty());
            assert_eq!(
                native
                    .code
                    .iter()
                    .map(|i| (i.pc, i.op, i.word & !255, i.aux))
                    .collect::<Vec<_>>(),
                p.code
                    .iter()
                    .map(|i| (i.pc, i.op, i.word & !255, i.aux))
                    .collect::<Vec<_>>()
            );
            let identical = normalized == compiled.stdout;
            whole_matches += usize::from(identical);
            assert_eq!(
                identical,
                debug != 0,
                "debug0omitslineinfo; debug1/2mustmatchentirepacket"
            );
            fs::write(
                artifacts.join(format!("model-O{optimization}D{debug}.bc")),
                &compiled.stdout,
            )
            .unwrap();
            evidence.push(json!({"optimization":optimization,"debug":debug,"semantic_fields_equal":true,"complete_normalized_packet_equal":identical,"compiler_bytes":compiled.stdout.len(),"compiler_bytecode_sha256":digest(&compiled.stdout)}));
        }
    }
    assert_eq!(whole_matches, 6);
    let report = json!({"schema":1,"executor":"Madium","executor_version":"2.0.0","client_pid_at_extraction":14180,"roblox_build":"0.746.0.7461267","place_id":3351674303u64,"extraction_date":"2026-11-10","native_target":"SocketTypes","target_path_provenance":"target name supplied by parent live probe; exact path belongs to live extraction report; original source unavailable","native_hex":NATIVE_HEX,"native_bytes":packet.len(),"native_sha256":digest(&packet),"normalized_sha256":digest(&normalized),"previous_probe_sha256":digest(&old),"differences_from_previous_probe":differences,"normalizer":"roblox_opcode227; instructionheaderbytesonly multiply203; AUXuntouched","upstream_revision":luau_decompiler::profiles::MODERN_REVISION,"compiler_sha256":compiler_hash,"compiler_flags":"LuauCompileFastpcall=true,DebugLuauUserDefinedClasses=false","original_source_provenance":"unknown","independent_source":{"prefix_blank_lines":90,"body":"return {}\n","return_line":91,"source_sha256":digest(source.as_bytes())},"semantic_fields":{"prototypes":1,"strings":0,"constants":0,"children":0,"max_stack":1,"parameters":0,"upvalues":0,"vararg":true,"instructions":["PREPVARARGS","NEWTABLE AUX0","RETURN R0 count1"]},"semantic_matches":9,"complete_packet_matches":whole_matches,"native_known_source_programs_verified":0,"native_execution_in_this_test":"not_run","scope":"Independent effect-free compiler model with six complete normalized byte matches; no original-source recovery or broad executor compatibility claim","cases":evidence});
    fs::write(
        root.join("docs/results/native-v3-model.json"),
        serde_json::to_vec_pretty(&report).unwrap(),
    )
    .unwrap();
}
