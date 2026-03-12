#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"

scripts_dir="$repo_root/home/.chezmoiscripts/darwin"
strict_mode=false
declare -a positional_args=()

for arg in "$@"; do
    case "$arg" in
    --strict)
        strict_mode=true
        ;;
    *)
        positional_args+=("$arg")
        ;;
    esac
done

discover_template() {
    local pattern="$1"
    local -a matches=()
    local path

    while IFS= read -r path; do
        matches+=("$path")
    done < <(compgen -G "$scripts_dir/$pattern" || true)

    if ((${#matches[@]} == 1)); then
        printf '%s\n' "${matches[0]}"
        return 0
    fi

    if ((${#matches[@]} == 0)); then
        echo "no script template matched pattern: $scripts_dir/$pattern" >&2
    else
        echo "multiple script templates matched pattern: $scripts_dir/$pattern" >&2
    fi
    return 1
}

formula_script_template="${positional_args[0]:-${BREW_FORMULA_SCRIPT_TEMPLATE:-}}"
cask_script_template="${positional_args[1]:-${BREW_CASK_SCRIPT_TEMPLATE:-}}"

if [[ -z "$formula_script_template" ]]; then
    formula_script_template="$(discover_template 'run_onchange_before_*install-brew-packages.sh.tmpl')"
fi

if [[ -z "$cask_script_template" ]]; then
    cask_script_template="$(discover_template 'run_onchange_before_*install-brew-casks.sh.tmpl')"
fi

if ! command -v brew >/dev/null 2>&1; then
    echo "brew is not installed" >&2
    exit 1
fi

if ! command -v chezmoi >/dev/null 2>&1; then
    echo "chezmoi is not installed" >&2
    exit 1
fi

if [[ ! -f "$formula_script_template" ]]; then
    echo "missing formula run script template: $formula_script_template" >&2
    exit 1
fi

if [[ ! -f "$cask_script_template" ]]; then
    echo "missing cask run script template: $cask_script_template" >&2
    exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
    echo "jq is required for dependency-aware formula reporting" >&2
    exit 1
fi

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

rendered_formula_script="$tmp_dir/rendered-formula-script.sh"
rendered_cask_script="$tmp_dir/rendered-cask-script.sh"

tracked_formula="$tmp_dir/tracked-formula.txt"
tracked_cask="$tmp_dir/tracked-cask.txt"
installed_formula="$tmp_dir/installed-formula.txt"
installed_cask="$tmp_dir/installed-cask.txt"
tracked_installed_formula="$tmp_dir/tracked-installed-formula.txt"
tracked_dependency_formula="$tmp_dir/tracked-dependency-formula.txt"
untracked_formula="$tmp_dir/untracked-formula.txt"
report_untracked_formula="$tmp_dir/report-untracked-formula.txt"
report_missing_formula="$tmp_dir/report-missing-formula.txt"
report_untracked_cask="$tmp_dir/report-untracked-cask.txt"
report_missing_cask="$tmp_dir/report-missing-cask.txt"

chezmoi execute-template <"$formula_script_template" >"$rendered_formula_script"
chezmoi execute-template <"$cask_script_template" >"$rendered_cask_script"

# Extract tracked entries by asking rendered run scripts for list mode.
# Normalize tap-qualified names (tap/repo/formula) to formula for stable comparisons.
bash "$rendered_formula_script" --list |
    awk -F/ '{print $NF}' |
    LC_ALL=C sort -u >"$tracked_formula"
bash "$rendered_cask_script" --list | LC_ALL=C sort -u >"$tracked_cask"

# Only report formulae that Homebrew currently considers explicitly user-installed.
# Use the latest install record to avoid stale historical metadata.
brew info --json=v2 --installed |
    jq -r '.formulae[]
        | . as $f
        | (($f.installed | last? // {}) as $latest
        | select($latest.installed_on_request == true and $latest.installed_as_dependency != true)
        | $f.name)' |
    LC_ALL=C sort -u >"$installed_formula"

brew list --cask | LC_ALL=C sort -u >"$installed_cask"

comm -12 "$tracked_formula" "$installed_formula" >"$tracked_installed_formula"

if [[ -s "$tracked_installed_formula" ]]; then
    mapfile -t tracked_formula_args <"$tracked_installed_formula"
    brew deps --installed --include-requirements --union "${tracked_formula_args[@]}" |
        awk -F/ '{print $NF}' |
        LC_ALL=C sort -u >"$tracked_dependency_formula"
else
    : >"$tracked_dependency_formula"
fi

comm -13 "$tracked_formula" "$installed_formula" >"$untracked_formula"

echo "== Formulae installed but not tracked =="
comm -23 "$untracked_formula" "$tracked_dependency_formula" >"$report_untracked_formula"
cat "$report_untracked_formula"

echo
echo "== Formulae tracked but not installed =="
comm -23 "$tracked_formula" "$installed_formula" >"$report_missing_formula"
cat "$report_missing_formula"

echo
echo "== Casks installed but not tracked =="
comm -13 "$tracked_cask" "$installed_cask" >"$report_untracked_cask"
cat "$report_untracked_cask"

echo
echo "== Casks tracked but not installed =="
comm -23 "$tracked_cask" "$installed_cask" >"$report_missing_cask"
cat "$report_missing_cask"

if [[ "$strict_mode" == true ]]; then
    if [[ -s "$report_untracked_formula" || -s "$report_missing_formula" || -s "$report_untracked_cask" || -s "$report_missing_cask" ]]; then
        echo >&2
        echo "brew state drift detected (strict mode)" >&2
        exit 1
    fi
fi
