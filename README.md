# Rc.4 controlled-program performance supplement

This archive contains performance measurements of owned, controlled programs. It contains the unchanged native and browser aggregate reports and all 35 compressed raw native reports. It contains no client capture, game corpus, classification, live-executor, private-session or authentication evidence and is independent of any archive awaiting authorization for such data.

The native measurements compare executable `5b1316e78fa183aafe32c46471ce31cb3601778a5650b26898e7a27743a7953d` with the recorded rc.3 executable. Inputs came from `benchmarks/generate-scale.ps1`: 2,000 independent programs, one function with 4,096 updates and one module with 512 functions. The owned input manifest and all 2,002 source/bytecode hash pairs were checked during this packaging audit without executing them. The original aggregate retains compiler, configuration, tool and source identities.

Browser measurements use `fixtures/runtime/verified.bc`, the controlled typed constant `local answer:number=42`, and the controlled strict-negative `local answer:number='wrong'`. The benchmark branch selects only these inputs. Its unchanged aggregate retains the actual browser/engine/definition identities, phase timings, cold/warm observations and limitations.

All four raw browser benchmark JSONs are withheld pending provenance-publication authorization because three include extraneous capture-availability metadata. None is selectively edited or redacted. This archive does not claim complete browser raw-reference coverage. Native raw-reference coverage is complete: all 35 included compressed reports match their aggregate SHA-256 references.

Extract to an empty directory and verify each original report against `member-manifest.json`. Project-relative members are under `reports/`; native raw paths in the aggregate resolve relative to `reports/docs/results/`. The ZIP sidecar binds the complete archive. Original bytes and original filesystem modification times are retained in the manifest; ZIP timestamps have two-second resolution. Existing workspace-metadata normalization in native raw reports is described by the unchanged aggregate; packaging performs no additional normalization.

These are local Windows measurements on a shared host with the displayed finite samples. Validation-disabled core timing, strict-analysis timing, verified-typed timing, browser initialization, warm work, allocations and memory retain their separate meanings. Timings do not establish behavioral equivalence, universal performance or CI certification of the locally measured executable. No scripts, test cases or benchmarks were run to create this archive; only recorded input/report identities and packaging integrity were checked.

This is publication staging only. Git or release publication must be established separately. No private-provenance archive, manifest or payload was used as a packaging input.
