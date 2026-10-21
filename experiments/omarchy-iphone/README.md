# REA / Omarchy iPhone bridge: optional static inspection experiment

This recipe uses the existing REA CLI to inspect a local noVNC JavaScript client or a desktop application's files. A separate Omarchy iPhone bridge supplies remote access; REA does not install an OS, replace iOS, stream the display, or change networking. This recipe is not part of packaged REA or its MCP catalog.

## Usage

On an Omarchy Linux host with REA installed independently, run the following from the REA repository checkout:

    bash experiments/omarchy-iphone/rea-audit.sh --target "$HOME/.local/share/omarchy-iphone-bridge/noVNC" --output "$HOME/rea-novnc-evidence.json" --mode javascript

Use --mode desktop with an explicitly selected installed-application directory for a bounded desktop installation inventory. The underlying REA commands are analyze-javascript-application and inspect-desktop-application. See docs/desktop-applications.md and docs/javascript-application-workflows.md for their interpretation and resource limits.

## Contract and safety

The input is an existing absolute local directory the caller is authorized to inspect. The output is a new absolute JSON file outside the input directory. Existing outputs are never overwritten. The wrapper writes a private same-directory temporary output, validates the JSON, publishes it without overwrite using a hard link, and removes the temporary output on exit.

REA may create its own ephemeral analysis workers per its existing workflows; the wrapper itself does not launch the selected target application, change source files, install software, configure remote access, reverse iOS protections, or make claims of native Omarchy iOS execution. Evidence may include local paths and private software metadata; protect it accordingly.

## Validation and proof gaps

External bridge package tests: 16/16 PASS on 2026-10-21, including mocked REA CLI invocation, output-preservation, invalid arguments, failure cleanup and target immutability. This is a mock boundary test only. This experiment has not been executed using real REA analysis nor a live Omarchy desktop, Tailscale network or iPhone. The report can support static code analysis, not live screen-capture or input validation.

Scope: an optional recipe only, no new provider, plugin, CLI or MCP contract, no build or release metadata modification. Any future production integration would require separate scope review and real-provider validation.