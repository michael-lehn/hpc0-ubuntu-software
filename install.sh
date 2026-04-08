#!/usr/bin/env bash
install_if_missing() {
    if ! dpkg -s "$1" 2>/dev/null | grep -q "^Status: install ok installed"; then
        echo "📦 Installing $1..."
	sudo apt-get install -y "$1"
    else
        echo "✔️  $1 already installed"
    fi
}

add_to_file() {
    local line="$1"
    local file="$2"

    # Create file if it does not exist
    touch "$file"

    # Check if line (without comment) already exists
    if ! grep -Fq "$line" "$file"; then
        echo "$line  # HPC0" >> "$file"
        echo "✅ Added to $file: $line"
    else
        echo "✔️ Already present in $file: $line"
    fi
}

clone_or_pull() {
    local repo_url="$1"
    local target_dir="$2"

    # If no target dir given → derive from repo name
    if [ -z "$target_dir" ]; then
        target_dir="$(basename "$repo_url" .git)"
    fi

    if [ -d "$target_dir/.git" ]; then
        echo "🔄 Updating $target_dir..." >&2
        git -C "$target_dir" pull
    else
        echo "📥 Cloning $repo_url into $target_dir..." >&2
        git clone "$repo_url" "$target_dir"
    fi
}

clone_or_pull_target_dir() {
    local repo_url="$1"
    local target_dir="$2"

    # If no target dir given → derive from repo name
    if [ -z "$target_dir" ]; then
        target_dir="$(basename "$repo_url" .git)"
    fi

    # Return the directory (absolute path is safer)
    (cd "$target_dir" && pwd)
}


safe_symlink() {
    local source="$1"
    local target="$2"

    # If target is already the correct symlink → nothing to do
    if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
        echo "✔️ Symlink already correct: $target -> $source"
        return
    fi

    # If target exists → create numbered backup
    if [ -e "$target" ] || [ -L "$target" ]; then
        local i=0
        while [ -e "${target}.bak$i" ] || [ -L "${target}.bak$i" ]; do
            i=$((i+1))
        done
        local backup="${target}.bak$i"

        echo "📦 Backing up $target to $backup"
        mv "$target" "$backup"
    fi

    # Ensure parent directory exists
    mkdir -p "$(dirname "$target")"

    echo "🔗 Creating symlink: $target -> $source"
    ln -s "$source" "$target"
}

is_wsl() {
    grep -qi microsoft /proc/version 2>/dev/null
}

install_nerd_font_linux() {
    local install_dir="$HOME/.local/share/fonts"

    mkdir -p "$install_dir"

    echo "📦 Installing Nerd Fonts for Linux from ./nerdfonts ..."
    cp -f nerdfonts/*.{ttf,otf} "$install_dir"/ 2>/dev/null || true
    fc-cache -f

    echo "Nerd Fonts installed for Linux."
}

countdown() {
    for i in $(seq 60 -1 1); do
	printf "\rAuto-skip in %2ds... " "$i"
	sleep 1
    done
    printf "\r                          \r"
}

install_nerd_font_wsl() {
    echo "📦 Install Nerd Fonts? (will open PowerShell as admin) [y/N]"

    # Countdown in background

    countdown &
    countdown_pid=$!

    if read -r -t 60 answer; then
        kill "$countdown_pid" 2>/dev/null
        wait "$countdown_pid" 2>/dev/null

        echo ""  # newline after input
        case "$answer" in
            [yY]|[yY][eE][sS])
                ./wsl-install-fonts.sh
                ;;
            *)
                echo "Skipping Nerd Fonts installation."
                ;;
        esac
    else
        kill "$countdown_pid" 2>/dev/null
        wait "$countdown_pid" 2>/dev/null

        echo ""
        echo "No input after 60 seconds → skipping Nerd Fonts installation."
    fi
}


#-------------------------------------------------------------------------------
# Update profile
#-------------------------------------------------------------------------------

# Detect shell profile
if [ -n "$ZSH_VERSION" ]; then
    PROFILE="$HOME/.zprofile"
else
    PROFILE="$HOME/.bashrc"
fi

#-------------------------------------------------------------------------------
# Install packages
#-------------------------------------------------------------------------------

echo "🔧 Updating package list..."
sudo apt update

echo "🔧 Upgrading packages..."
sudo apt -y upgrade

install_if_missing make
install_if_missing eza
install_if_missing g++
install_if_missing npm
install_if_missing rustup
install_if_missing zip
install_if_missing clang-format
install_if_missing black
install_if_missing konsole
install_if_missing curl
install_if_missing python3-venv
install_if_missing python3-pip
install_if_missing autoconf
install_if_missing libtool
install_if_missing autoconf-archive
install_if_missing pkg-config
install_if_missing libncurses5-dev
install_if_missing latexmk
install_if_missing okular

if [ "$SESSION_TYPE" = "wayland" ]; then
    install_if_missing wl-clipboard
else
    install_if_missing xclip
fi

if ! command -v llvm-config-21 >/dev/null 2>&1; then
    echo "📦 Installing llvm (version 21)"
    wget https://apt.llvm.org/llvm.sh
    chmod +x llvm.sh
    sudo ./llvm.sh 21
fi

install_if_missing texlive-latex-recommended
install_if_missing texlive-latex-extra
install_if_missing texlive-pictures
install_if_missing texlive-science
install_if_missing texlive-fonts-recommended
install_if_missing texlive-latex-extra
install_if_missing texlive-pictures
install_if_missing texlive-lang-german
install_if_missing texlive-luatex

echo "📦 Installing neovim-remote (nvr)"
add_to_file 'PATH=$PATH:~/.local/bin' "$PROFILE"
source "$PROFILE"
pip3 install --user --break-system-packages neovim-remote
add_to_file "alias texvim='SOCKET=/tmp/nvim; rm -f \$SOCKET; nvim --listen \$SOCKET'" "$PROFILE"
mkdir -p ~/.config
if command -v kwriteconfig5 >/dev/null 2>&1; then
    kwriteconfig5 --file okularpartrc --group "Core General" --key EditorType "Custom"
    kwriteconfig5 --file okularpartrc --group "Core General" --key ExternalEditor "nvr --servername /tmp/nvim --remote +%l %f"
elif command -v kwriteconfig6 >/dev/null 2>&1; then
    kwriteconfig6 --file okularpartrc --group "Core General" --key EditorType "Custom"
    kwriteconfig6 --file okularpartrc --group "Core General" --key ExternalEditor "nvr --servername /tmp/nvim --remote +%l %f"
else
    cat >> ~/.config/okularpartrc <<'EOF'

[Core General]
EditorType=Custom
ExternalEditor=nvr --servername /tmp/nvim --remote +%l %f
EOF
fi


echo "📦 Installing ruff"
sudo snap install ruff --classic

echo "📦 Installing nvim"
url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage"
curl -fL -o nvim-linux-x86_64.appimage "$url"
chmod u+x nvim-linux-x86_64.appimage
sudo mv nvim-linux-x86_64.appimage /usr/local/bin/nvim

echo "📦 Installing cargo"
rustup default stable
add_to_file 'PATH=$PATH:~/.cargo/bin' "$PROFILE"

echo "📦 Installing tree-sitter command line interface"
cargo install --locked tree-sitter-cli

#-------------------------------------------------------------------------------
# Configure Neovim
#-------------------------------------------------------------------------------

echo "📦 Configure neovim"
git_repos=https://github.com/michael-lehn/neovim-config-lsp
clone_or_pull $git_repos
NVIM_DIR="$(clone_or_pull_target_dir $git_repos)"
safe_symlink "$NVIM_DIR" "$HOME/.config/nvim"
add_to_file "alias vim=nvim" "$PROFILE"

#-------------------------------------------------------------------------------
# Configure nano
#-------------------------------------------------------------------------------

echo "📦 Configure nano"
git_repos=https://github.com/michael-lehn/nano-config.git
clone_or_pull $git_repos
NANO_DIR="$(clone_or_pull_target_dir $git_repos)"
safe_symlink "$NANO_DIR"/nanorc "$HOME/.nanorc"
safe_symlink "$NANO_DIR"/nano "$HOME/.nano"

#-------------------------------------------------------------------------------
# Configure shell
#-------------------------------------------------------------------------------
echo "📦 Configure shell to use vi mode"
add_to_file 'set -o vi' "$PROFILE"
add_to_file "alias ls=eza" "$PROFILE"

#-------------------------------------------------------------------------------
# Configure clang-format
#-------------------------------------------------------------------------------

echo "📦 Configure clang-format"
git_repos=https://github.com/michael-lehn/clang-format.git
clone_or_pull $git_repos
CF_DIR="$(clone_or_pull_target_dir $git_repos)"
safe_symlink "$CF_DIR"/clang-format "$HOME/.clang-format"

#-------------------------------------------------------------------------------
# Build abc
#-------------------------------------------------------------------------------

echo "📦 Building and installing abc compiler"
git_repos=https://github.com/michael-lehn/abc-llvm.git
clone_or_pull $git_repos
ABC_DIR="$(clone_or_pull_target_dir $git_repos)"
(cd "$ABC_DIR" && make && sudo make install)

#-------------------------------------------------------------------------------
# Build finalcut
#-------------------------------------------------------------------------------

echo "📦 Building and installing finalcut library"
git_repos=https://github.com/michael-lehn/finalcut.git
clone_or_pull $git_repos
FC_DIR="$(clone_or_pull_target_dir $git_repos)"
(cd "$FC_DIR" && autoreconf --install --force; \
    autoreconf --install --force \
    && ./configure --prefix=/usr/local && make && sudo make install)


#-------------------------------------------------------------------------------
# Build and test ULM generator
#-------------------------------------------------------------------------------

echo "📦 Building and testing ULM generator"
git_repos=https://github.com/michael-lehn/ulm-generator.git
clone_or_pull $git_repos
UG_DIR="$(clone_or_pull_target_dir $git_repos)"
(cd "$UG_DIR" && sudo make install)

ulm-generator --fetch ulm-ice40.isa
ulm-generator --install ulm-ice40.isa
echo "10100020202100001402000004000004302000001211000105FFFFFB0141000068656C6C6F2C20776F726C64210A00" > hello
ulm hello

#-------------------------------------------------------------------------------
# Installing Nerd fonts
#-------------------------------------------------------------------------------

install_nerd_font_linux
if is_wsl; then
    ./wsl-konsole.sh
    ./wsl-terminal.sh
    ./wsl-keybindings.sh
    install_nerd_font_wsl
fi
