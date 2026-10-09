#!/usr/bin/env bash
# Renders the built-in themes with the real candidate panel (ThemeRenderProbe), horizontal
# and vertical, for the website: <out>/<id>-linear.png and <id>-stacked.png (@2x).
#   bash scripts/render-themes.sh [<out-dir>]     default: ../kume-web/public/themes/renders
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${1:-$ROOT/../kume-web/public/themes/renders}"
mkdir -p "$OUT"
OUT="$(cd "$OUT" && pwd)"
SCHEMES="$(python3 -c 'import json,sys; print(",".join(t["id"] for t in json.load(open(sys.argv[1]))))' \
  "$ROOT/Packages/KUMEKit/Tests/KUMECoreTests/Fixtures/theme-v1/valid.json" | tr ',' '\n' | grep -v -e sakura_test -e low_contrast | paste -sd, -)"
KUME_RENDER_FRONTEND="$ROOT/SharedSupport/kume.yaml" KUME_RENDER_OUT="$OUT" KUME_RENDER_PREEDIT=1 KUME_RENDER_SCHEMES="$SCHEMES" \
  swift test --package-path "$ROOT/Packages/KUMEKit" --filter ThemeRenderProbe >/dev/null
echo "rendered images: $(find "$OUT" -name "*.png" | wc -l | tr -d " ")"
