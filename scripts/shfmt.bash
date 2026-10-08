#!/usr/bin/env bash
set -euo pipefail

mode="-d"
if [[ "${1:-}" == "--write" || "${1:-}" == "-w" ]]; then
  mode="-w"
  shift
fi

if (($# == 0)); then
  cd "$(dirname "${BASH_SOURCE[0]}")/.."
  set -- scripts/*.bash home/dot_bashrc home/dot_bash_profile
fi

exec shfmt -ln bash -i 2 -ci "$mode" "$@"
