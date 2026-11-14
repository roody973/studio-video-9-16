#!/bin/bash
# Convertit une séquence PNG (ZIP exporté par Studio Vidéo 9:16) en MP4 H.264.
# Usage : ./sequence-vers-mp4.sh sequence-30fps-90img.zip
#         ./sequence-vers-mp4.sh sequence-30fps-90img.zip 60    # si tu as choisi 60 im/s
set -euo pipefail

ZIP="${1:?Indique le fichier .zip exporté par le studio}"
FPS="${2:-30}"
FF="${FFMPEG:-$HOME/.hermes/tools/ffmpeg-9.0.1-darwin-arm64/ffmpeg}"
[ -x "$FF" ] || FF="$(command -v ffmpeg || true)"
[ -x "$FF" ] || { echo "ffmpeg introuvable. Installe-le ou passe FFMPEG=/chemin/ffmpeg"; exit 1; }

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
unzip -q "$ZIP" -d "$WORK"

DIR="$(find "$WORK" -type d -name frames | head -1)"
[ -n "$DIR" ] || { echo "Dossier frames/ absent du zip."; exit 1; }
COUNT=$(ls "$DIR"/*.jpg | wc -l | tr -d ' ')
OUT="$(pwd)/$(basename "${ZIP%.zip}").mp4"

echo "Images : $COUNT — cadence : $FPS im/s — durée : $(echo "$COUNT / $FPS" | bc -l | cut -c1-5) s"
"$FF" -hide_banner -loglevel error -y \
  -framerate "$FPS" -i "$DIR/frame_%05d.jpg" \
  -c:v libx264 -profile:v high -pix_fmt yuv420p -crf 18 \
  -movflags +faststart -r "$FPS" "$OUT"

echo "Fichier : $OUT"
"$FF" -hide_banner -i "$OUT" 2>&1 | grep -E 'Duration|Video:' || true
