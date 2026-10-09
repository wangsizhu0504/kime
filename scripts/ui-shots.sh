#!/usr/bin/env bash
# Captures KUME Settings panes in light and dark mode into .ui-acceptance/<date>/.
#   bash scripts/ui-shots.sh [pane ...]
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="${APP:-$ROOT/build/DerivedData/Build/Products/Debug/KUME Settings.app}"
PROCESS_NAME="${KUME_UI_PROCESS_NAME:-KUME Settings}"
OUT="${KUME_UI_OUT:-$ROOT/.ui-acceptance/$(date +%Y-%m-%d)}"
mkdir -p "$OUT"
# Never point automation at the real workspace: screenshots run against a throwaway
# copy (config only — no userdb, no build/ except what the UI reads).
SANDBOX="$(mktemp -d -t kume-ui)"
SRC="${KUME_UI_SOURCE:-$HOME/Library/KUME/Rime}"
if [[ -d "$SRC" ]]; then
  rsync -a --exclude '*.userdb' --exclude 'sync' --exclude '*.gram' --exclude 'cn_dicts' "$SRC/" "$SANDBOX/"
fi
# Usage statistics are sandboxed the same way (optionally seeded from KUME_UI_STATS_SOURCE).
STATS="$(mktemp -d -t kume-ui-stats)"
if [[ -n "${KUME_UI_STATS_SOURCE:-}" && -d "$KUME_UI_STATS_SOURCE" ]]; then rsync -a "$KUME_UI_STATS_SOURCE/" "$STATS/"; fi
CREDENTIALS="$STATS/credentials.json"
# A synthetic non-empty value skips legacy Keychain migration during UI capture.
printf '%s\n' '{"openai-compatible":"ui-fixture-no-api-key"}' > "$CREDENTIALS"
chmod 600 "$CREDENTIALS"
trap 'rm -rf "$SANDBOX" "$STATS"' EXIT
# AI configuration is shared through features.json. Sanitize the temporary copy,
# never the user's file, before opening any pane.
python3 - "$SANDBOX/kume/features.json" <<'PYTHON'
import json, pathlib, sys
path = pathlib.Path(sys.argv[1])
features = json.loads(path.read_text()) if path.exists() else {}
features.update(aiBaseURL="https://api.example.com/v1", aiModel="example-model", aiRemoteAllowed=False)
path.parent.mkdir(parents=True, exist_ok=True)
path.write_text(json.dumps(features))
PYTHON
PANES=("$@"); [[ ${#PANES[@]} -gt 0 ]] || PANES=(overview appearance schemas spelling dictionaries phrases snippets stats ai advanced)
WINDOW_ID_SCRIPT="$(mktemp -t winid).swift"
cat > "$WINDOW_ID_SCRIPT" <<'SWIFT'
import CoreGraphics
let list = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as! [[String: Any]]
let owner = CommandLine.arguments[1]
// With a pid, only that process's window: a Settings window the user has open elsewhere
// (same name) must never be captured.
let pid = CommandLine.arguments.count > 2 ? Int(CommandLine.arguments[2]) : nil
for w in list where (w[kCGWindowLayer as String] as? Int) == 0
    && (pid.map { (w[kCGWindowOwnerPID as String] as? Int) == $0 } ?? ((w[kCGWindowOwnerName as String] as? String) == owner)) {
    print(w[kCGWindowNumber as String]!); break
}
SWIFT
WINDOW_ID_BIN="$(mktemp -t winid-bin)"
swiftc -O "$WINDOW_ID_SCRIPT" -o "$WINDOW_ID_BIN"
for mode in light dark; do
  for pane in "${PANES[@]}"; do
    pkill -f "$APP/Contents/MacOS/" 2>/dev/null || true
    sleep 0.5
    open -n --env KUME_USER_DIR="$SANDBOX" --env KUME_STATS_DIR="$STATS" --env KUME_CREDENTIALS_FILE="$CREDENTIALS" "$APP" --args --pane "$pane" --appearance "$mode" ${KUME_UI_ARGS:-}
    # Wait for the window instead of a fixed delay (first launch of a new build is slow).
    wid=""
    for _ in $(seq 1 15); do
      sleep 1
      pid="$(pgrep -n -f "$APP/Contents/MacOS/" || true)"
      wid="$([[ -n "$pid" ]] && "$WINDOW_ID_BIN" "$PROCESS_NAME" "$pid" 2>/dev/null || true)"
      [[ -n "$wid" ]] && break
    done
    if [[ -z "$wid" ]]; then
      # The first launch of a freshly signed build sometimes comes up without its window.
      pkill -f "$APP/Contents/MacOS/" 2>/dev/null || true
      sleep 1
      open -n --env KUME_USER_DIR="$SANDBOX" --env KUME_STATS_DIR="$STATS" --env KUME_CREDENTIALS_FILE="$CREDENTIALS" "$APP" --args --pane "$pane" --appearance "$mode" ${KUME_UI_ARGS:-}
      for _ in $(seq 1 15); do
        sleep 1
        pid="$(pgrep -n -f "$APP/Contents/MacOS/" || true)"
      wid="$([[ -n "$pid" ]] && "$WINDOW_ID_BIN" "$PROCESS_NAME" "$pid" 2>/dev/null || true)"
        [[ -n "$wid" ]] && break
      done
    fi
    [[ -n "$wid" ]] || { echo "window for $pane ($mode) did not appear" >&2; exit 1; }
    sleep "${KUME_UI_SETTLE:-1.5}"
    screencapture -l "$wid" -o "$OUT/settings-$pane-$mode.png"
    # Minimum window size (the native counterpart of a "mobile" check).
    osascript -e 'on run argv' -e 'tell application "System Events" to tell (first process whose unix id is ((item 1 of argv) as integer)) to set size of window 1 to {900, 620}' -e 'end run' "$pid" >/dev/null 2>&1 || true
    sleep 0.8
    screencapture -l "$wid" -o "$OUT/settings-$pane-$mode-narrow.png"
    echo "captured $pane ($mode, default + narrow)"
  done
done
pkill -f "$APP/Contents/MacOS/" 2>/dev/null || true
