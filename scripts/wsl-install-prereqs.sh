#!/usr/bin/env bash
# Task 5 of the WSL+config-sharing plan.
# Installs build tooling, Neovim from upstream, the Rust toolchain, and tree-sitter CLI.
# Run on Ubuntu WSL: bash /mnt/d/Workspace/my-config-files/scripts/wsl-install-prereqs.sh
# Will prompt for sudo password a few times.

set -euo pipefail

TREE_SITTER_VERSION="v0.26.1"

echo "=== 1/5 apt install build-essential + utilities ==="
sudo apt update
sudo apt install -y build-essential git curl unzip ripgrep fd-find xclip ca-certificates

echo
echo "=== 2/5 install Neovim from upstream tarball ==="
cd /tmp
curl -L -o nvim-linux-x86_64.tar.gz \
  https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
rm -f /tmp/nvim-linux-x86_64.tar.gz
echo "nvim installed:"
nvim --version | head -1

echo
echo "=== 3/5 install rustup + stable + nightly toolchain ==="
if ! command -v rustup >/dev/null 2>&1; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
    | sh -s -- -y --default-toolchain stable --profile default --no-modify-path
fi
. "$HOME/.cargo/env"
rustup component add rust-src rust-analyzer rustfmt clippy
rustup toolchain install nightly --component rustfmt --profile minimal
echo "rust toolchain:"
rustc --version
cargo --version
rustup which rust-analyzer
cargo +nightly fmt --version

echo
echo "=== 4/5 install tree-sitter CLI ${TREE_SITTER_VERSION} (for nvim-treesitter main branch) ==="
mkdir -p "$HOME/.local/bin"
cd /tmp
curl -fsSL -o tree-sitter.gz \
  "https://github.com/tree-sitter/tree-sitter/releases/download/${TREE_SITTER_VERSION}/tree-sitter-linux-x64.gz"
gunzip -f tree-sitter.gz
chmod +x tree-sitter
mv -f tree-sitter "$HOME/.local/bin/tree-sitter"
"$HOME/.local/bin/tree-sitter" --version

echo
echo "=== 5/5 PATH wiring for non-interactive login shells ==="
# Ubuntu's default ~/.bashrc returns early for non-interactive shells, so wiring
# cargo only from there breaks `wsl.exe -- bash -lc ...` invocations that nvim/mason
# rely on. Wire from ~/.profile (read by login shells regardless of interactivity).
PROFILE="$HOME/.profile"
touch "$PROFILE"
if ! grep -qsF '.cargo/env' "$PROFILE"; then
  {
    echo ''
    echo '# Rust toolchain (needed in non-interactive login shells: nvim, mason, etc.)'
    echo '[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"'
  } >> "$PROFILE"
  echo "appended cargo env to ~/.profile"
fi
# ~/.profile already adds ~/.local/bin via the default Ubuntu snippet, so tree-sitter
# is reachable. No further PATH work needed.

echo
echo "=== DONE ==="
echo "Open a fresh shell or run \`source ~/.profile\` to pick up the PATH changes."
