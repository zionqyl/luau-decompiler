# Public rc.5 Windows acceptance

This sanitized receipt is generated from the actual post-publication local records. It complements the canonical CI reports in the [release evidence archive](https://github.com/zionqyl/luau-decompiler/releases/download/v0.4.0-rc.5/luau-decompiler-0.4.0-rc.5-evidence.zip); it does not replace or retimestamp them. Original local receipt hashes are retained without machine paths, credentials or captured bytecode.

Installation required a safe retry after its first bounded bootstrap deadline. Uninstall subsequently recovered a sandbox-denied metadata replacement using the same verified installer bytes. Both failures are retained below. The public executable and three source outputs were checked against their published/tagged bytes. Item used its recorded generation configuration plus the explicit CLI override `--policy verified-typed`; Button and InventoryService used annotated/check policy. The latter two have source and successful reconstruction but failed strict and meaningful typing.

```json
{
  "schema": 1,
  "scope": "Post-publication Windows acceptance on the development host; not a fresh consumer OS or a new whole-corpus pass",
  "source_commit": "090c1e64635c6af7344973a283b164e9e5f944d8",
  "tag": "v0.4.0-rc.5",
  "runtime_archive": {
    "name": "luau-decompiler-0.4.0-rc.5-windows-x64.zip",
    "bytes": 5577821,
    "sha256": "41b45bbdd4e13fc6e2f46e0a682a772efe218d592bc227e26c412c1da3bc2371"
  },
  "executable_sha256": "9cd4c98f8ec0b19ef1084fbd6d3593b44c99725eacd3c1930a813b8b5d796d31",
  "analyzer_sha256": "ff04e80cb3e1024b138bf92a06f0214cb4438adf1a1abc13f26b0975fe6e5451",
  "analyzer_manifest_sha256": "767d0992778e3f4ce5f4a8d92244e787faf82da8a21778a7acb93dca2d6785d9",
  "definitions_sha256": "d6d1e40a142fc3dcb1a70759256fb990d1110953dfd7eef667ff254b2e5b54af",
  "installer_sha256": "ead5cb1d736996260c20e93c6c224374c0087d8f93a184da7d3c6da740e0597b",
  "runtime_acceptance": {
    "passed": true,
    "case_count": 10,
    "cases": [
      {
        "id": "runtime_quality_tool_provenance_matches_packaged_assets",
        "passed": true
      },
      {
        "id": "stdin_file_verified_source",
        "passed": true
      },
      {
        "id": "failed_verified_source_kept_with_nonzero_status",
        "passed": true
      },
      {
        "id": "bounded_mixed_extension_source_batch",
        "passed": true
      },
      {
        "id": "missing_analyzer_strict_benchmark_retains_complete_failed_report",
        "passed": true
      },
      {
        "id": "verified_bytecode_and_exact_typed_behavior",
        "passed": true
      },
      {
        "id": "http_verified_bytecode",
        "passed": true
      },
      {
        "id": "authenticated_http_verified_source_negative_and_24_concurrent_requests",
        "passed": true
      },
      {
        "id": "exact_attribution_cli_batch_http_cache_and_failed_quality",
        "passed": true
      },
      {
        "id": "authenticated_graceful_shutdown",
        "passed": true
      }
    ],
    "behavioral_scope": "one_known_source_program; one_exact_LOBS_1_pair; no_arbitrary_input_execution",
    "harness_sha256": "345179804b19ddc310e690c88bcd93220b832e783369c75d2fd48a6367ec2779"
  },
  "captured_output_parity": {
    "passed": true,
    "scope": "Three retained buffers processed statically by exact published/installed CLI; no game-code execution or full-corpus claim",
    "rows": [
      {
        "name": "Button",
        "kind": "gameplay",
        "input_sha256": "f60ede0f9aa568532ff89e71fc46282ce4a5f70ccaa87afb07e99e0b1831afed",
        "source_sha256": "5053f1d84240f9cfdc3328fc82b59e144a82ed6b06d56328ad6cdc098a30f65a",
        "source_bytes": 4067,
        "reconstruction_complete": true,
        "syntax": "passed",
        "compilation": "passed",
        "strict_analysis": "failed",
        "output_policy": "annotated",
        "required_passed": true,
        "byte_identical_to_checked_in_engine_output": true,
        "game_code_executed": false,
        "meaningful_typing_passed": false
      },
      {
        "name": "InventoryService",
        "kind": "gameplay",
        "input_sha256": "54dddafc02f0c2287df13336f760035f4178f0ff7dd3fdb0404de5a0abace984",
        "source_sha256": "f87c5ea00f0e79e0ce747bd4067da9fae9d310b3a1bc0bf160551075d0f45329",
        "source_bytes": 9750,
        "reconstruction_complete": true,
        "syntax": "passed",
        "compilation": "passed",
        "strict_analysis": "failed",
        "output_policy": "annotated",
        "required_passed": true,
        "byte_identical_to_checked_in_engine_output": true,
        "game_code_executed": false,
        "meaningful_typing_passed": false
      },
      {
        "name": "Item",
        "kind": "data_only",
        "input_sha256": "d5eec5039688d4fcaf2a90874818727311bf1e2e8eca968ad58ea1c2132fef78",
        "source_sha256": "ddf3193f95b0859091884ff67a59f8c2d3d4b87651984ff8c1a30da1f11e910a",
        "source_bytes": 1095062,
        "reconstruction_complete": true,
        "syntax": "passed",
        "compilation": "passed",
        "strict_analysis": "passed",
        "output_policy": "verified_typed",
        "required_passed": true,
        "byte_identical_to_checked_in_engine_output": true,
        "game_code_executed": false,
        "meaningful_typing_passed": true
      }
    ]
  },
  "installation": {
    "first_online_attempt": "recorded atomic scheduling deadline; owned intent preserved, same command retry succeeded",
    "first_online_attempt_not_counted_as_success": true,
    "same_command_retry_passed": true,
    "main_tag_bytes_agree": true,
    "path_changes": "NoPath isolated; default PATH activation not repeated in this public-boundary run"
  },
  "uninstall": {
    "passed": true,
    "owned_executable_removed": true,
    "uninstalled_ownership_marker_preserved": true,
    "unowned_configuration_preserved": true,
    "first_attempt": "Sandbox denied atomic replacement with Win32 5 after owned files were removed",
    "recovery": "Same verified public installer bytes resumed outside sandbox; stored atomic intent retained"
  },
  "original_local_receipts": [
    {
      "name": "availability.json",
      "sha256": "c59641379eb4507a6defea71e639b146121b571840408b2e88dcb7eb364de163"
    },
    {
      "name": "installation.json",
      "sha256": "937cb2a6a9d847d4d8657b1e4b524e6654e53f2a20849b0b33ac7690bf9527b6"
    },
    {
      "name": "runtime-command.json",
      "sha256": "aabfa32f027cf7753ce6ad9389a5126d7e09470eda33be116526a251eebf0f3b"
    },
    {
      "name": "runtime-acceptance.json",
      "sha256": "e46cb07d61152294d19999e1807b7b51c8bba4baa9ce5f2246e9367503c5c82a"
    },
    {
      "name": "captured-output-parity.json",
      "sha256": "b934353457585c35f64f02b215440fe94ce36238272a2e588e89a92b11d76a55"
    },
    {
      "name": "uninstall-acceptance.json",
      "sha256": "6464843ef1654fddefd04dcf7752d9abd5ed8332cf828a7e6195b221b1b377bf"
    }
  ]
}
```
