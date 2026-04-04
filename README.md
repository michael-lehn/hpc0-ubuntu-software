# HPC0 Ubuntu Software Setup

This repository installs the software required for the **HPC0 (Introduction to
High Performance Computing)** course on Ubuntu.

## Usage (for the impatient)

Open a new terminal, copy the following line, and press Enter:

```
sudo apt install -y git && ( [ -d hpc0-ubuntu-software/.git ] && cd hpc0-ubuntu-software && git pull && ./install.sh || git clone https://github.com/michael-lehn/hpc0-ubuntu-software.git && cd hpc0-ubuntu-software && ./install)
```

## Usage (for those who want to know what is happening)

### First time
From your home directory (or wherever you want), clone the repository, change
into it, and run `./install`:

```
git clone https://github.com/michael-lehn/hpc0-ubuntu-software.git
cd hpc0-ubuntu-software
./install
```

### If you have already cloned the repository before
Change into the repository, pull the latest changes, and run ./install again:

```
cd hpc0-ubuntu-software
git pull
./install
```
## Credits

Thanks to Theo for helping to set up a clean and reliable Ubuntu installation process.
