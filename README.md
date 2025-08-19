# dotfiles 😥 💻

Collection of personal dotfiles (keys, configs, functions, etc.).

Managed via [chezmoi](https://www.chezmoi.io/).

## Installation

More OS come when I actually have them ✌️.

### macOS

```bash
# 1) Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Load Homebrew into your shell for this session
eval "$(/opt/homebrew/bin/brew shellenv)"

# 2) Install chezmoi
brew install chezmoi

# 3) Initialize and apply this dotfiles repo
chezmoi init zerospiel --apply
chezmoi apply
```

## Thanks

- Thanks [Tom Payne](https://github.com/twpayne) for [chezmoi](https://www.chezmoi.io/).
- Inspired by [Dhruvin Shah](https://github.com/dhruvinsh) with [dotfiles](https://github.com/dhruvinsh/dotfiles/tree/main).
