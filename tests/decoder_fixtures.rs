use luau_decompiler::{bytecode, Limits};
use serde::Deserialize;
use sha2::{Digest, Sha256};
use std::path::PathBuf;

#[derive(Deserialize)]
struct Manifest {
    upstream_revision: String,
    fixtures: Vec<Fixture>,
}
#[derive(Deserialize)]
struct Fixture {
    source: String,
    source_sha256: String,
    optimization: u8,
    debug: u8,
    bytecode: String,
    sha256: String,
}

fn fixtures() -> (PathBuf, Manifest) {
    let directory = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("tests/fixtures");
    let json = std::fs::read(directory.join("manifest.json"))
        .expect("run scripts/generate-fixtures.ps1 with the pinned compiler");
    (
        directory,
        serde_json::from_slice(&json).expect("fixture manifest"),
    )
}

#[test]
fn official_compiler_matrix_decodes_and_has_integrity() {
    let (directory, manifest) = fixtures();
    assert_eq!(manifest.upstream_revision, bytecode::UPSTREAM_REVISION);
    assert!(!manifest.fixtures.is_empty());
    let corpus = directory.parent().unwrap().join("corpus");
    let mut counts = std::collections::BTreeMap::<String, [[bool; 3]; 3]>::new();
    for fixture in manifest.fixtures {
        let bytes = std::fs::read(directory.join(&fixture.bytecode)).unwrap();
        assert_eq!(
            format!("{:x}", Sha256::digest(&bytes)),
            fixture.sha256,
            "fixture {} changed",
            fixture.bytecode
        );
        let source = std::fs::read(corpus.join(&fixture.source)).unwrap();
        assert_eq!(
            format!("{:x}", Sha256::digest(&source)),
            fixture.source_sha256,
            "source {} changed: regenerate fixtures",
            fixture.source
        );
        let module = bytecode::decode(&bytes, &Limits::default())
            .unwrap_or_else(|e| panic!("{}: {e}", fixture.bytecode));
        assert_eq!(module.version, 6);
        assert_eq!(module.type_version, 3);
        assert!(!module.protos.is_empty());
        counts.entry(fixture.source).or_default()[fixture.optimization as usize]
            [fixture.debug as usize] = true;
    }
    for (source, settings) in counts {
        assert!(
            settings.iter().flatten().all(|v| *v),
            "incomplete optimization/debug matrix: {source}"
        );
    }
}

#[test]
fn all_fixture_truncations_are_errors() {
    let (directory, manifest) = fixtures();
    for fixture in manifest.fixtures {
        let bytes = std::fs::read(directory.join(&fixture.bytecode)).unwrap();
        for end in 0..bytes.len() {
            assert!(
                bytecode::decode(&bytes[..end], &Limits::default()).is_err(),
                "accepted truncated {} at {end}/{}",
                fixture.bytecode,
                bytes.len()
            );
        }
    }
}

#[test]
fn fixture_mutations_are_bounded_and_never_panic() {
    let (directory, manifest) = fixtures();
    let limits = Limits {
        max_bytes: 65536,
        max_strings: 512,
        max_string_bytes: 32768,
        max_protos: 128,
        max_instructions: 8192,
        max_constants: 2048,
        max_depth: 32,
        ..Limits::default()
    };
    for fixture in manifest.fixtures {
        let original = std::fs::read(directory.join(&fixture.bytecode)).unwrap();
        let mut bytes = original.clone();
        for n in (0..bytes.len()).step_by(7) {
            for mask in [1, 0x80, 0xff] {
                bytes[n] ^= mask;
                let _ = bytecode::decode(&bytes, &limits);
                bytes[n] = original[n];
            }
        }
    }
}
