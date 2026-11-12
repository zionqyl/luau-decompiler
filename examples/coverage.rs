use luau_decompiler::{
    bytecode::{decode_with_options, detected_encoding, Opcode},
    execution::{CancellationToken, ExecutionContext, MemoryBudget},
    Limits,
};
use serde_json::json;
use sha2::{Digest, Sha256};
use std::collections::BTreeMap;
use std::io::Read;
use std::path::PathBuf;
use std::time::{Duration, Instant};

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut directory = PathBuf::from("tests/fixtures");
    let mut manifest = None;
    let mut encoding = String::from("upstream");
    let mut arguments = std::env::args().skip(1);
    while let Some(argument) = arguments.next() {
        match argument.as_str() {
            "--manifest" => {
                manifest = Some(PathBuf::from(arguments.next().ok_or("missing manifest")?))
            }
            "--encoding" => encoding = arguments.next().ok_or("missing encoding")?,
            value if !value.starts_with('-') => directory = value.into(),
            _ => return Err(format!("unknown coverage argument {argument}").into()),
        }
    }
    let config = luau_decompiler::Config {
        bytecode_encoding: encoding.clone(),
        ..Default::default()
    };
    config.validate()?;
    let mut paths: Vec<PathBuf> = if let Some(manifest) = manifest {
        let mut contents = Vec::new();
        std::fs::File::open(manifest)?
            .take(8 * 1024 * 1024 + 1)
            .read_to_end(&mut contents)?;
        if contents.len() > 8 * 1024 * 1024 {
            return Err("manifest exceeds 8 MiB".into());
        }
        serde_json::from_slice(&contents)?
    } else {
        std::fs::read_dir(directory)?
            .map(|entry| entry.map(|entry| entry.path()))
            .collect::<Result<Vec<_>, _>>()?
            .into_iter()
            .filter(|path| path.extension().is_some_and(|extension| extension == "bc"))
            .collect()
    };
    if paths.len() > 50000 {
        return Err("coverage exceeds 50000 inputs".into());
    }
    paths.sort();
    let mut opcodes: BTreeMap<String, usize> = BTreeMap::new();
    let mut inputs = Vec::new();
    let mut prototypes = 0;
    let mut rejected = Vec::new();
    let mut total_bytes = 0usize;
    let limits = Limits::default();
    for path in &paths {
        let mut bytes = Vec::new();
        std::fs::File::open(path)?
            .take(limits.max_bytes as u64 + 1)
            .read_to_end(&mut bytes)?;
        total_bytes = total_bytes
            .checked_add(bytes.len())
            .ok_or("input accounting overflow")?;
        if total_bytes > 512 * 1024 * 1024 {
            return Err("coverage exceeds 512 MiB total input".into());
        }
        let digest = format!("{:x}", Sha256::digest(&bytes));
        let context = ExecutionContext::new(
            CancellationToken::default(),
            Some(Instant::now() + Duration::from_secs(2)),
        )
        .with_work_limit(limits.max_analysis_steps)
        .with_memory(MemoryBudget::new(256 * 1024 * 1024))?;
        let module = luau_decompiler::execution::with_context(context, || {
            decode_with_options(&bytes, &limits, "auto", &encoding)
        });
        let module = match module {
            Ok(module) => module,
            Err(error) => {
                rejected.push(json!({"file":path.file_name(),"path":path,"bytes":bytes.len(),"input_sha256":digest,"detected_encoding":detected_encoding(&bytes),"error":error}));
                continue;
            }
        };
        prototypes += module.protos.len();
        let mut instructions = 0;
        for proto in &module.protos {
            for instruction in &proto.code {
                *opcodes.entry(format!("{:?}", instruction.op)).or_default() += 1;
                instructions += 1;
            }
        }
        inputs.push(json!({"file": path.file_name(), "path":path,"input_sha256":digest,"detected_encoding":detected_encoding(&bytes),"bytes": bytes.len(), "prototypes": module.protos.len(), "instructions": instructions}));
    }
    let mut unobserved = Vec::new();
    for value in 0..=u8::MAX {
        if let Some(opcode) = Opcode::from_byte(value) {
            let name = format!("{opcode:?}");
            if !opcodes.contains_key(&name) {
                unobserved.push(name);
            }
        }
    }
    let all_decoded = rejected.is_empty();
    println!(
        "{}",
        serde_json::to_string_pretty(
            &json!({"upstream_revision": luau_decompiler::UPSTREAM_REVISION,
        "version":env!("CARGO_PKG_VERSION"),"encoding":encoding,"all_decoded":all_decoded,"fixture_count": paths.len(),"decoded_count":inputs.len(),"rejected_count":rejected.len(),"total_input_bytes":total_bytes,"rejected_inputs":rejected,"prototype_count": prototypes, "observed_opcode_count": opcodes.len(),
        "opcode_occurrences": opcodes, "unobserved_opcodes": unobserved, "inputs": inputs,
        "meaning": "compiler corpus observation only; unobserved opcodes have no corpus behavioral coverage, and decoder/unit coverage is reported separately"})
        )?
    );
    if !all_decoded {
        return Err("one or more inputs failed validated decoding; see rejected_inputs".into());
    }
    Ok(())
}
