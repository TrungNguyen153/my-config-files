#!/usr/bin/env bash
# Task 5 of the WSL+config-sharing plan.
# Installs build tooling, Neovim from upstream, and the Rust toolchain.
# Run on Ubuntu WSL: bash /mnt/d/Workspace/my-config-files/scripts/wsl-install-prereqs.sh
# Will prompt for sudo password a few times.

set -euo pipefail

echo "=== 1/4 apt install build-essential + utilities ==="
sudo apt update
sudo apt install -y build-essential git curl unzip ripgrep fd-find xclip ca-certificates

echo
echo "=== 2/4 install Neovim from upstream tarball ==="
cd /tmp
curl -L -o nvim-linux-x86_64.tar.gz \
  https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
rm -f /tmp/nvim-linux-x86_64.tar.gz
echo "nvim installed:"
nvim --version | head -1

echo
echo "=== 3/4 install rustup + stable toolchain ==="
if ! command -v rustup >/dev/null 2>&1; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
    | sh -s -- -y --default-toolchain stable --profile default --no-modify-path
fi
# Ensure cargo is on PATH for the rest of this script
. "$HOME/.cargo/env"
rustup component add rust-src rust-analyzer rustfmt clippy
rustup toolchain install nightly --component rustfmt --profile minimal
echo "rust toolchain:"
rustc --version
cargo --version
rustup which rust-analyzer
cargo +nightly fmt --version

echo
echo "=== 4/4 PATH check ==="
if ! grep -qs '\.cargo/env' "$HOME/.bashrc" "$HOME/.profile" 2>/dev/null; then
  echo '. "$HOME/.cargo/env"' >> "$HOME/.bashrc"
  echo "Added '. \$HOME/.cargo/env' to ~/.bashrc"
fi

echo
echo "=== DONE — Task 5 complete ==="
echo "Next: tell Claude to continue. Tasks 6-9 are automatable from here."
