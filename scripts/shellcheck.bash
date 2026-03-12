#!/usr/bin/env bash
set -euo pipefail

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

# Lint regular shell scripts directly.
shellcheck -s bash -x \
  scripts/*.bash

# Lint chezmoi script templates after rendering to valid shell.
for tmpl in home/.chezmoiscripts/*/*.sh.tmpl; do
  rendered="$tmp_dir/$(basename "$tmpl" .tmpl)"
  chezmoi execute-template <"$tmpl" >"$rendered"
  shellcheck -s bash -x "$rendered"
done
