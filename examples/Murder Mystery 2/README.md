# Murder Mystery 2 client snapshot

Owner-authorized, client-accessible Luau outputs, preserving observed service and instance hierarchy. The decompiler's MIT license does not license the game's code. Roblox engine content and uncertain dependencies are excluded.

[Manifest and per-file quality](manifest.json) | [Scope](scope.json) | [Capture, generations and limitations](../../docs/client-corpus.md)

## Current and historical outputs

The corpus contains 297 documents. Rc.5 refreshes three retained byte buffers: [Button](ReplicatedStorage/ClientServices/Button.luau), [InventoryService](ReplicatedStorage/ClientServices/InventoryService.luau) and the data-only [Item](ReplicatedStorage/Database/Sync/Item.luau). All three reconstruct and compile. Only Item passes both strict analysis and meaningful typing. Button and InventoryService remain unverified; annotations and the strict directive do not establish verification.

The other 294 documents retain their historical rc.4 output and generation identities. Composite totals are not a full rc.5 corpus pass. The manifest records current-subset denominators separately. The browser showcase serves the three current outputs on demand; historical documents remain available here.

The reviewed scope contains 340 distinct objects, observed 547 times; 339 objects supplied 209 unique buffers. Historical rc.4 processing reconstructed 182 buffers into 297 object documents, with 52 strict-passing buffers and 38 passing both strict and meaningful typing. Forty-three objects have no generated document, including one unsupported extraction context. Failures and repeated observations remain in the manifest; no placeholders are published.

Original bytes remain private. No captured script was executed as a behavioral test. This snapshot does not cover server-only scripts, later-loaded objects or unobserved instances. The recognized signature container does not establish cryptographic authenticity. Attribution credits the decompiler, not the original game developer; erased notices are not invented.

The user confirmed owner permission on 2026-11-12. Historical receipts retain the rights information available when they were recorded. Current per-file configuration links, hashes and generation provenance are in the manifest; [historical settings](generation.config.json) are not relabeled as current.
