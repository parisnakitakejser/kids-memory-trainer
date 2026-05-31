#!/usr/bin/env bash
set -euo pipefail

MAX_SIZE="${MAX_IMAGE_SIZE:-512}"

if ! command -v sips >/dev/null 2>&1; then
  echo "sips is required to optimize images on macOS." >&2
  exit 1
fi

optimize_folder() {
  local source_dir="$1"
  local output_dir="$2"

  mkdir -p "$output_dir"
  find "$output_dir" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \) -delete

  while IFS= read -r -d '' source_file; do
    file_name="$(basename "${source_file%.*}").jpg"
    output_file="$output_dir/$file_name"

    sips \
      --resampleHeightWidthMax "$MAX_SIZE" \
      --setProperty format jpeg \
      --setProperty formatOptions 74 \
      "$source_file" \
      --out "$output_file" >/dev/null
  done < <(find "$source_dir" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \) -print0 | sort -z)

  if ! find "$output_dir" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \) | grep -q .; then
    touch "$output_dir/.gitkeep"
  fi

  original_size="$(du -sh "$source_dir" | awk '{print $1}')"
  optimized_size="$(du -sh "$output_dir" | awk '{print $1}')"

  echo "Optimized images: $source_dir ($original_size) -> $output_dir ($optimized_size)"
}

if [ "$#" -ge 1 ]; then
  default_output="build_assets/${1#assets/}"
  optimize_folder "$1" "${2:-$default_output}"
  exit 0
fi

optimize_folder "assets/animals" "build_assets/animals"
optimize_folder "assets/numbers" "build_assets/numbers"
optimize_folder "assets/letters/en" "build_assets/letters/en"
optimize_folder "assets/letters/da" "build_assets/letters/da"
optimize_folder "assets/colors" "build_assets/colors"
