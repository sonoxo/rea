#!/usr/bin/env bash
# Optional REA read-only client inspection recipe. No software installation.
set -Eeuo pipefail
umask 077

usage() {
  cat <<'HELP'
Usage: rea-audit.sh --target ABSOLUTE_DIR --output ABSOLUTE_JSON [--mode javascript|desktop]
Run a static REA inspection and save JSON Evidence to a new file.
  javascript: analyze-javascript-application (e.g. noVNC; default)
  desktop:    inspect-desktop-application (e.g. a local app directory)
Never installs packages, launches target software or changes remote access settings.
It does not make Omarchy boot natively on iPhone.
HELP
}
fail() { printf 'BLOCKED: %s\n' "$*" >&2; exit 1; }
TARGET=''
OUTPUT=''
MODE=javascript
while (($#)); do
  case "$1" in
    --target|--output|--mode)
      flag="$1"
      (($# >= 2)) || fail "Missing value for $flag"
      value="$2"
      case "$flag" in
        --target) TARGET="$value" ;;
        --output) OUTPUT="$value" ;;
        --mode) MODE="$value" ;;
      esac
      shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) fail "Unknown option: $1" ;;
  esac
done
[[ "$MODE" == javascript || "$MODE" == desktop ]] || fail 'Mode must be javascript or desktop'
[[ "$TARGET" == /* && -d "$TARGET" ]] || fail 'Target must be an existing absolute directory'
[[ "$OUTPUT" == /* && "$OUTPUT" == *.json ]] || fail 'Output must be an absolute .json path'
[[ ! -e "$OUTPUT" && ! -L "$OUTPUT" ]] || fail 'Output already exists (never overwritten)'
command -v rea >/dev/null 2>&1 || fail 'REA CLI not installed; see official rea-agents setup documentation'
command -v python3 >/dev/null 2>&1 || fail 'Python 3 required to check file boundaries and Evidence format'

# Do not write into the inspected directory, even temporarily.
python3 - "$TARGET" "$OUTPUT" <<'PY' || fail 'Output must be outside the selected target directory'
from pathlib import Path
import sys
target = Path(sys.argv[1]).resolve(strict=True)
output = Path(sys.argv[2]).resolve(strict=False)
if target == output or target in output.parents:
    sys.exit(1)
if not output.parent.is_dir():
    sys.exit(1)
PY

output_dir="$(dirname -- "$OUTPUT")"
temporary="$(mktemp "$output_dir/.rea-audit.XXXXXXXX")" || fail 'Cannot create private temporary Evidence file'
cleanup() { rm -f -- "$temporary"; }
trap cleanup EXIT

if [[ "$MODE" == javascript ]]; then
  rea analyze-javascript-application "$TARGET" --json > "$temporary" || fail 'REA JavaScript analysis failed; no Evidence published'
else
  rea inspect-desktop-application "$TARGET" --detail complete --json > "$temporary" || fail 'REA desktop inspection failed; no Evidence published'
fi
[[ -s "$temporary" ]] || fail 'REA produced no Evidence'
python3 -m json.tool "$temporary" >/dev/null || fail 'REA did not return valid JSON Evidence'
# Atomic, non-overwriting publication on one filesystem.
ln -- "$temporary" "$OUTPUT" || fail 'Output appeared concurrently or cannot be created; no overwrite performed'
python3 - "$OUTPUT" <<'PY'
from pathlib import Path
import hashlib, sys
p = Path(sys.argv[1])
h = hashlib.sha256()
with p.open('rb') as evidence:
    for chunk in iter(lambda: evidence.read(1024 * 1024), b''):
        h.update(chunk)
print('PASS: REA static Evidence created: ' + str(p))
print('SHA-256: ' + h.hexdigest())
print('Size: ' + str(p.stat().st_size) + ' bytes')
print('Live iPhone/Omarchy connectivity remains NOT VERIFIED.')
PY
