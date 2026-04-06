# HPC0 Ubuntu Software Setup

This repository installs the software required for the **HPC0 (Introduction to
High Performance Computing)** course on Ubuntu.

## Usage (for the impatient)

Open a new terminal, copy the following line, and press Enter:

```
sudo apt install -y git && ( [ -d hpc0-ubuntu-software/.git ] && cd hpc0-ubuntu-software && git pull && ./install.sh || git clone https://github.com/michael-lehn/hpc0-ubuntu-software.git && cd hpc0-ubuntu-software && ./install.sh) && source ~/.bashrc
```

## What will be installed

This script installs the main software and tools used in the HPC0 course:

- `git`, GNU `make`, the GNU C/C++ compiler, and the LLVM toolchain (including libraries)
- The ABC compiler and the ULM generator
- `konsole` (from the KDE project), which I consider the best terminal emulator
  on Linux

In addition, the system is configured to some extent according to my personal
preferences (which you are not required to share). Details on how to undo these
changes are given below. For now, here is what is modified:

- `ls` is aliased to `eza` to provide a more colorful and informative output
- `vim` is aliased to `nvim` (Neovim), as I consider it the better Vim
- `nvim` is installed along with my configuration and a set of plugins I find
  useful  (your existing Neovim configuration will not be overwritten; a backup
  is created)
- Nerd Fonts are installed so that file icons and symbols display correctly in
  Neovim

### If you do not like these changes

- All modifications to `~/.bashrc` are marked with the comment `HPC0`  → you can remove these lines at any time
- If you want to restore your previous Neovim configuration: a backup has been created in `~/.config` with a name like  `nvim.bak<unique-id>`

## For WSL users

If you are not using Linux via dual boot, you should first install WSL.  
After that, you can simply run `./install.sh` as described above.  
For most purposes, this is all you need.

However, if you want to use Nerd Fonts, there are a few additional things to be
aware of:

1. At the end of the installation, the script will ask whether you also want to
   install Nerd Fonts on Windows. You have 60 seconds to respond.
   - If you answer yes, a PowerShell window will open and you will need to
     enter your Windows administrator password
   - If you miss the prompt or change your mind later, you can run
     `./wsl-install-fonts.sh` manually (or rerun `./install.sh`, which will
     take longer)

2. After installing Nerd Fonts, you need to select one of them in your WSL
   terminal settings.  For example: `JetBrainsMonoNLNerdFontMono`, or simply
   search for "nerd" and pick one

## Usage (for those who want to know what is happening)

### First time
From your home directory (or wherever you want), clone the repository, change
into it, run `./install`, and source `~/.bashrc`:

```
git clone https://github.com/michael-lehn/hpc0-ubuntu-software.git
cd hpc0-ubuntu-software
./install
source ~/.bashrc
```

### If you have already cloned the repository before
Change into the repository, pull the latest changes, run ./install again,
and source `~/.bashrc`:

```
cd hpc0-ubuntu-software
git pull
./install
source ~/.bashrc
```
## Credits

Thanks to Theo for helping to set up a clean and reliable Ubuntu installation process.
