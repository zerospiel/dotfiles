#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
strict_mode=false
case "${1:-}" in
  --strict) strict_mode=true ;;
  "") ;;
  *)
    echo "Usage: $0 [--strict]" >&2
    exit 1
    ;;
esac

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

chezmoi --source "$repo_root" execute-template '{{ includeTemplate "Brewfile" . }}' >"$tmp_dir/Brewfile"
brew bundle list --file="$tmp_dir/Brewfile" --formula |
  awk -F/ '{print $NF}' | sort -u >"$tmp_dir/tracked-formula"
brew bundle list --file="$tmp_dir/Brewfile" --cask |
  sort -u >"$tmp_dir/tracked-cask"

brew info --json=v2 --installed >"$tmp_dir/installed.json"
jq -r '.formulae[].name' "$tmp_dir/installed.json" |
  sort -u >"$tmp_dir/installed-formula"
# installation intent only affects which extra packages are reported
jq -r '.formulae[] | select(
  (.installed | last? // {}) |
  .installed_on_request == true and .installed_as_dependency != true
) | .name' "$tmp_dir/installed.json" |
  sort -u >"$tmp_dir/requested-formula"
brew list --cask --full-name | sort -u >"$tmp_dir/installed-cask"

comm -12 "$tmp_dir/tracked-formula" "$tmp_dir/installed-formula" >"$tmp_dir/tracked-installed"
tracked_formula_args=()
while IFS= read -r formula; do
  tracked_formula_args+=("$formula")
done <"$tmp_dir/tracked-installed"
if ((${#tracked_formula_args[@]})); then
  brew deps --installed --include-requirements --union "${tracked_formula_args[@]}" |
    awk -F/ '{print $NF}' | sort -u >"$tmp_dir/dependencies"
else
  : >"$tmp_dir/dependencies"
fi

comm -13 "$tmp_dir/tracked-formula" "$tmp_dir/requested-formula" >"$tmp_dir/untracked-formula"
comm -23 "$tmp_dir/untracked-formula" "$tmp_dir/dependencies" >"$tmp_dir/extra-formula"
comm -23 "$tmp_dir/tracked-formula" "$tmp_dir/installed-formula" >"$tmp_dir/missing-formula"
comm -13 "$tmp_dir/tracked-cask" "$tmp_dir/installed-cask" >"$tmp_dir/extra-cask"
comm -23 "$tmp_dir/tracked-cask" "$tmp_dir/installed-cask" >"$tmp_dir/missing-cask"

drift=false
for category in extra-formula missing-formula extra-cask missing-cask; do
  case "$category" in
    extra-formula) echo "== Formulae installed but not tracked ==" ;;
    missing-formula) echo "== Formulae tracked but not installed ==" ;;
    extra-cask) echo "== Casks installed but not tracked ==" ;;
    missing-cask) echo "== Casks tracked but not installed ==" ;;
  esac
  cat "$tmp_dir/$category"
  echo
  [[ ! -s "$tmp_dir/$category" ]] || drift=true
done

if [[ "$strict_mode" == true && "$drift" == true ]]; then
  echo "brew state drift detected (strict mode)" >&2
  exit 1
fi
