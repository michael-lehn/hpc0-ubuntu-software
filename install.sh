echo "🔧 Updating package list..."
sudo apt update

echo "🔧 Upgrading packages..."
sudo apt update

if ! command -v llvm-config-21 >/dev/null 2>&1; then
    echo "📦 Installing llvm (version 21)"
    wget https://apt.llvm.org/llvm.sh
    chmod +x llvm.sh
    sudo ./llvm.sh 21
fi
echo "📦 Installing llvm (version 21)"
sudo apt install -y make g++ npm rustup zip clang-format black konsole curl

echo "📦 Installing ruff"
sudo snap install ruff --classic

echo "📦 Installing nvim"
sudo snap install nvim --classic

echo "📦 Installing cargo"
rustup default stable

echo "📦 Installing tree-sitter command line interface"
cargo install --locked tree-sitter-cli

grep -q 'HPC0_PATH_CARGO' ~/.bashrc || \
    echo 'PATH=$PATH:~/.cargo/bin      # HPC0_PATH_CARGO' >> ~/.bashrc

grep -q 'HPC0_ALIAS_VIM' ~/.bashrc || \
    echo 'alias vim=nvim	# HPC0_ALIAS_VIM' >> ~/.bashrc

echo "🔧 Cloning or updateing neovim config repository"
repo_dir="neovim-config-lsp"
if [ -d "$repo_dir/.git" ]; then
    git -C "$repo_dir" pull
else
    git clone https://github.com/michael-lehn/neovim-config-lsp "$repo_dir"
fi

echo "🔧 Cloning or updating abc-llvm repository"
repo_dir="abc-llvm"
if [ -d "$repo_dir/.git" ]; then
    git -C "$repo_dir" pull
else
    git clone https://github.com/michael-lehn/abc-llvm.git
fi

echo "📦 Linking neovim config"
mkdir -p $HOME/.config
nvim_dir="$HOME/.config/nvim"
if [ -e "$nvim_dir" ] || [ -L "$nvim_dir" ]; then
    i=1
    while [ -e "${nvim_dir}.bak$i" ] || [ -L "${nvim_dir}.bak$i" ]; do
        i=$((i+1))
    done
    mv "$nvim_dir" "${nvim_dir}.bak$i"
fi
ln -s "$PWD"/neovim-config-lsp ~/.config/nvim

echo "📦 Building abc compiler"
cd abc-llvm && make && sudo make install

if [ ! -e "$HOME/.clang-forma" ] && [ ! -L "$HOME/.clang-format" ]; then
    echo "📦 Linking clang format"
    ln -s "$PWD/clang-format" "~/.clang-format"
fi


FONT_NAME="JetBrainsMono"
VERSION="3.2.1"
URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v${VERSION}/${FONT_NAME}.zip"

INSTALL_DIR="$HOME/.local/share/fonts"

mkdir -p "$INSTALL_DIR"
cd /tmp

# Nur herunterladen, wenn noch nicht vorhanden
if ! fc-list | grep -qi "JetBrainsMono Nerd Font"; then
    echo "Installing Nerd Font: $FONT_NAME"

    wget -q "$URL" -O nerd-font.zip
    unzip -q nerd-font.zip -d nerd-font

    cp nerd-font/*.ttf "$INSTALL_DIR"/

    fc-cache -f

    echo "Nerd Font installed."
else
    echo "Nerd Font already installed."
fi

echo "🔧 sourcing ~/.bashrc"
. ~/.bashrc
