#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR="${1:-assets/animals}"
OUTPUT_DIR="${2:-build_assets/animals}"
MAX_SIZE="${MAX_IMAGE_SIZE:-512}"

if ! command -v sips >/dev/null 2>&1; then
  echo "sips is required to optimize images on macOS." >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

find "$OUTPUT_DIR" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \) -delete

while IFS= read -r -d '' source_file; do
  file_name="$(basename "${source_file%.*}").jpg"
  output_file="$OUTPUT_DIR/$file_name"

  sips \
    --resampleHeightWidthMax "$MAX_SIZE" \
    --setProperty format jpeg \
    --setProperty formatOptions 74 \
    "$source_file" \
    --out "$output_file" >/dev/null
done < <(find "$SOURCE_DIR" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \) -print0 | sort -z)

original_size="$(du -sh "$SOURCE_DIR" | awk '{print $1}')"
optimized_size="$(du -sh "$OUTPUT_DIR" | awk '{print $1}')"

echo "Optimized animal images: $SOURCE_DIR ($original_size) -> $OUTPUT_DIR ($optimized_size)"
