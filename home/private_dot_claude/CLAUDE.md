# Global instructions

## Environment
- macOS, Homebrew bash 5 (not zsh). GNU sed is first in PATH; other coreutils are BSD.
- Containers: podman, never docker. kind uses KIND_EXPERIMENTAL_PROVIDER=podman.
- Dotfiles are managed by chezmoi (~/.local/share/chezmoi). Edit the source, never the
  file in ~ (it gets overwritten). Never run `chezmoi apply` without asking.
- Don't install tools globally (brew, go install, npm -g) without asking. If one is
  needed permanently, add it to the Brewfile or the go-bins list in the chezmoi source.

## Before acting
- Ask first for anything irreversible or visible to others: push, tags, releases,
  PR or issue comments, deleting files outside the repo.
- Kubernetes: check `kubectl config current-context` first; only kind-* contexts
  are fair game without asking.
- Check the installed version (`--help`, `go doc`) instead of guessing flags or APIs.

## Git
- Conventional Commits: `type(scope): summary`, imperative, lower-case, ≤72 chars.
- Commit body: brief, no flowery language; where possible a bullet list of
  changes as `what: why`.
- Commits are SSH-signed; never use --no-gpg-sign or touch signing config.
- Never add Co-Authored-By trailers or any other AI attribution to commits or PRs
  unless I explicitly ask for it in the current conversation.
- Never commit secrets, .env files, or kubeconfigs.

## Go
- gofumpt + goimports; lint with `golangci-lint run` (v2 config).
- Table-driven tests; `go test -race ./...` when touching concurrency.
- Wrap errors with %w. Don't bump the go directive unasked.

## Comments
- New inline comments start with a lower-case letter and have no trailing period,
  unless I say otherwise. Leave existing comments as they are.

## Shell
- bash with `set -euo pipefail`; must pass shellcheck and `shfmt -i 2 -ci`.

## Finishing
- Before saying "done", run the relevant tests/linters and show the result.
  If you couldn't run them, say so explicitly.
- Keep diffs minimal; don't reformat code you didn't change.
