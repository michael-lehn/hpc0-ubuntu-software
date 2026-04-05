echo "🔧 Updating package list..."
sudo apt update

echo "🔧 Upgrading packages..."
sudo apt upgrade

if ! command -v llvm-config-21 >/dev/null 2>&1; then
    echo "📦 Installing llvm (version 21)"
    wget https://apt.llvm.org/llvm.sh
    chmod +x llvm.sh
    sudo ./llvm.sh 21
fi
echo "📦 Installing llvm (version 21)"
sudo apt install -y make g++ npm rustup zip clang-format black konsole curl
sudo apt install -y python3.12-venv
sudo apt install -y autoconf
sudo apt install -y libtool
sudo apt install -y autoconf-archive
sudo apt install -y pkg-config
sudo apt install -y libncurses5-dev

if [ "$SESSION_TYPE" = "wayland" ]; then
    echo "📦 Installing wl-clipboard..."
    sudo apt install -y wl-clipboard
else
    echo "📦 Installing xclip (fallback for X11 or unknown)..."
    sudo apt install -y xclip
fi

#sudo apt install -y texlive-full
sudo apt install -y \
  texlive-latex-recommended \
  texlive-latex-extra \
  texlive-pictures \
  texlive-science \
  texlive-fonts-recommended
sudo apt install -y texlive-latex-extra texlive-pictures

echo "📦 Installing ruff"
sudo snap install ruff --classic

echo "📦 Installing nvim"
curl -LO https://github.com/neovim/neovim/releases/download/v0.12.0/nvim-linux-x86_64.appimage
chmod u+x nvim-linux-x86_64.appimage
sudo mv nvim-linux-x86_64.appimage /usr/local/bin/nvim

echo "📦 Installing cargo"
rustup default stable

echo "📦 Installing tree-sitter command line interface"
cargo install --locked tree-sitter-cli

grep -q 'HPC0_PATH_CARGO' ~/.bashrc || \
    echo 'PATH=$PATH:~/.cargo/bin      # HPC0_PATH_CARGO' >> ~/.bashrc

grep -q 'HPC0_ALIAS_VIM' ~/.bashrc || \
    echo 'alias vim=nvim	# HPC0_ALIAS_VIM' >> ~/.bashrc

grep -q 'HPC0_SETO' ~/.bashrc || \
    echo 'set -o vi	# HPC0_SETO' >> ~/.bashrc


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
(cd abc-llvm && make && sudo make install)

if [ ! -e "$HOME/.clang-format" ] && [ ! -L "$HOME/.clang-format" ]; then
    echo "📦 Linking clang format"
    echo ln -s "$PWD/clang-format" "~/.clang-format"
    ln -s "$PWD/clang-format" ~/.clang-format
fi

echo "🔧 Cloning or updating finalcut repository"
repo_dir="finalcut"
if [ -d "$repo_dir/.git" ]; then
    git -C "$repo_dir" pull
else
    git clone https://github.com/michael-lehn/finalcut.git
fi

echo "📦 Building finalcut library"
(cd finalcut && autoreconf --install --force; autoreconf --install --force  && ./configure --prefix=/usr/local && make && sudo make install)

echo "🔧 Cloning or updating ulm-generator repository"
repo_dir="ulm-generator"
if [ -d "$repo_dir/.git" ]; then
    git -C "$repo_dir" pull
else
    git clone https://github.com/michael-lehn/ulm-generator.git
fi

echo "📦 Installing ULM generator"
(cd ulm-generator && sudo make install)

echo "📦 Testing ULM generator"
ulm-generator --fetch ulm-ice40.isa
ulm-generator --install ulm-ice40.isa
echo "10100020202100001402000004000004302000001211000105FFFFFB0141000068656C6C6F2C20776F726C64210A00" > hello
ulm hello

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
