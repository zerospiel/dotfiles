#!/usr/bin/env bash
set -euo pipefail

mode="-d"

if [[ "${1:-}" == "--write" || "${1:-}" == "-w" ]]; then
  mode="-w"
  shift
fi

target="${1:-.}"

exec shfmt -i 2 -ci "$mode" "$target"
