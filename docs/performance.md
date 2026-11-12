# Performance evidence

The [candidate performance report](performance-rc.md) describes the matched rc.1/rc.2 comparison, measured phases, allocation counters and reproducible commands. A measured executable is identified by its hash; results from a pre-optimization candidate do not validate a later binary. Consult the report's completion status before quoting final-candidate numbers.

The [v0.3 report](performance-v3.md), [v0.3 service measurements](evidence.md), and [v0.2 report](performance-v2.md) are historical. Their programs, configurations, tools, cache states and binaries define their scope. Historical parent-only service memory excludes analyzer subprocesses and is not aggregate memory.

Faithful and annotated core measurements with validation disabled are not verified-typed latency. Cold startup, warmed analyzer work, analyzer-result hits, whole-service cache hits, source processing and complete adapter transport are distinct paths. Small sample sizes and shared-host interference remain visible. Earlier failed native transport probes and manual MCP comparisons do not establish current adapter latency. Current successful requests, when present, are identified separately by exact executable, adapter, program and policy.

Performance measurements do not establish behavioral equivalence, strict success, platform compatibility or release readiness. Those remain independent [validation gates](validation.md).
