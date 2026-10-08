#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

shellcheck -s bash -x scripts/*.bash home/dot_bashrc home/dot_bash_profile

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

for personal in true false; do
  for template in home/.chezmoiscripts/*/*.sh.tmpl home/dot_profile.tmpl home/dot_profile.d/*.sh.tmpl; do
    rendered="$tmp_dir/$personal/$template.sh"
    mkdir -p "$(dirname "$rendered")"
    # omit credential fragments while checking the surrounding template logic
    sed '/{{.*| decrypt.*}}/d' "$template" |
      chezmoi --config /dev/null --config-format yaml --source "$repo_root" \
        execute-template --override-data "{\"personalMachine\":$personal,\"chezmoi\":{\"os\":\"darwin\"}}" >"$rendered"
    shellcheck -s bash -x "$rendered"
  done
done
