# Sonoxo REA <-> GPT-Chaos Kraken bridge (optional)

**Purpose:** record the supported relationship between the Sonoxo REA fork and the GPT-Doug/GPT-Chaos implementation without modifying REA's own CLI, MCP contracts, package, providers, or installer.

- REA upstream: https://github.com/morluto/rea (MIT, version 6.7.0 used by the smoke-test contract).
- Sonoxo fork: https://github.com/sonoxo/rea
- Python bridge: https://github.com/sonoxo/gpt-doug-llm/tree/feat/rea-kraken-swarm-20261021/gpt_chaos
- Review gate: https://github.com/sonoxo/gpt-doug-llm/pull/455
- XUNIA catalog: the GPT-Doug branch includes an opt-in, local-only prototype entry in docs/resources.json, not a hosted reverse-engineering service.

## Operator workflow (macOS / Linux)

Install REA independently from the official upstream documentation using supported Node.js. The official npm release pin for this experimental bridge is rea-agents@6.7.0. This experiment does not auto-install Node, npm, Ghidra, Hopper, or REA.

From a GPT-Doug checkout containing PR #455:

    mkdir -p "$HOME/rea-evidence"
    gpt-chaos rea --mode javascript --target "/absolute/path/to/your-owned-app" --output "$HOME/rea-evidence"

The first call **only plans** the inspection. To run against a target you own or are explicitly authorized to inspect, add `--execute --authorized`. The bridge processes at most eight local targets with at most four concurrent subprocesses and records private JSON evidence and its SHA-256 digest.

For approved multi-machine evidence review, copy the complete, private evidence directories using your existing authorized process and use:

    gpt-chaos rea-verify --manifest "/absolute/path/to/siteA/manifest.json" --manifest "/absolute/path/to/siteB/manifest.json"

The offline verifier compares bytes, hashes, structured fields, and validated evidence locations. Hashes do not authenticate the producer or prove conclusions, and a copied evidence bundle may contain private paths. Do not publish these outputs to XUNIA.

## Verifiable boundary

- No modification to REA source, binaries, agent configuration, or native-analysis providers in this fork.
- GPT-Chaos bridge runs only documented local REA JavaScript/Electron and desktop-inspection commands. External REA behavior remains governed by its own tools and upstream policies.
- An emergency stop in the existing GPT-Doug runtime is checked around worker processes; it does not remotely police every other tool.
- No propagation, unsolicited target scanning, remote worker execution, license bypass, device installation, or automatic website publication.
- PR #455 has 22 local mock tests, a dedicated Linux/macOS integration gate, and a passed real REA 6.7.0 synthetic-fixture smoke. The implementation remains subject to review before any production deployment. A real REA 6.7.0 synthetic-fixture check has passed in the companion PR, but full application coverage and production deployment remain unverified.

The existing `experiments/omarchy-iphone/` static-audit work remains separate: it does not make Omarchy run natively on iPhone. This bridge is optional and does not assert a live iPhone connection.
