# Bashrc Config Dotfiles

A personal dotfiles repository for managing and deploying Bash and Tmux configurations across Linux machines.

This repository provides an automated installation script that backs up existing configurations and creates symbolic links to the version-controlled configuration files.

## Contents

```text
bashrc-config/
├── .bashrc          # Bash configuration and custom prompt
├── .tmux.conf       # Tmux configuration
├── install.sh       # Automated installation script
├── bash/            # Additional Bash configuration files
└── README.md
```

## Features

- Automated installation of Bash and Tmux configurations.
- Automatic backup of existing configuration files.
- Unique backup filenames to prevent accidental overwriting.
- Symbolic links connecting configuration files to this repository.
- Detection of existing symbolic links.
- Preservation of symbolic links pointing to other locations.
- Support for configurable target home and dotfiles directories.
- Independent installation attempts for each configuration.
- Idempotent installation: running the installer repeatedly does not create unnecessary backups.

## Prerequisites

Before installing, ensure that your system has:

- A Linux environment (Ubuntu, Debian, WSL, or another compatible distribution).
- Bash.
- Git.
- Standard GNU utilities: `cp`, `rm`, `ln`, `realpath`, and `mkdir`.

Git is required only to clone the repository. The installer itself does not require root privileges when installing into your own home directory.

## Installation

### 1. Clone the repository

Open a terminal and execute:

```bash
git clone https://github.com/AyushShuklaIIT/bashrc-config.git ~/.dotfiles
```

This downloads the repository into `~/.dotfiles`.

### 2. Run the installer

Execute:

```bash
~/.dotfiles/install.sh
```

If the executable permission is missing, use:

```bash
bash ~/.dotfiles/install.sh
```

### 3. Reload Bash configuration

To apply the Bash configuration immediately:

```bash
source ~/.bashrc
```

For Tmux, start a new Tmux session. If Tmux is already running, reload its configuration using:

```bash
tmux source-file ~/.tmux.conf
```

## What the installer does

The installer currently manages two configuration files:

| Repository file | Destination |
|---|---|
| `.bashrc` | `~/.bashrc` |
| `.tmux.conf` | `~/.tmux.conf` |

For each configuration, the installer performs the following checks:

1. Verifies that the source configuration exists in the repository.
2. Checks whether the destination is already a symbolic link.
3. If the symbolic link points to the intended source, skips installation.
4. If the symbolic link points elsewhere, displays a warning and leaves it unchanged.
5. If a regular configuration file exists, creates a backup before replacing it.
6. Generates a numbered backup filename if the default backup filename already exists.
7. Removes the original file and creates a symbolic link to the repository configuration.
8. If the destination does not exist, creates the symbolic link directly.

### Backup naming

Existing configuration files are preserved using the following naming convention:

```text
.bashrc.backup
.bashrc.backup.1
.bashrc.backup.2
```

The same convention applies to `.tmux.conf`.

Existing backups are never intentionally overwritten.

## Warnings and considerations

- **Review your existing configuration:** The installer replaces regular destination files with symbolic links after backing them up.
- **Existing symbolic links:** Links pointing to another location are skipped rather than overwritten.
- **Missing source files:** If a configuration is missing from the repository, its installation fails.
- **Partial installation:** The installer attempts both configurations independently. One failure does not prevent the other installation from being attempted.
- **Machine-specific settings:** Review configurations before deploying them on a different machine. Paths, dependencies, and environment variables may differ.
- **Sensitive information:** Never commit passwords, access tokens, private SSH keys, or other credentials to this public repository.
- **Git identity:** Git identity settings are intentionally kept local rather than included in this repository.
- **Rust environment:** The Bash configuration loads `~/.cargo/env` only when that file exists, allowing systems without Rust installed to use the configuration.
- **Backups:** Keep your backups until you have verified that the new configurations work correctly.

## Verifying the installation

Check the symbolic links:

```bash
ls -l ~/.bashrc ~/.tmux.conf
```

Inspect their destinations:

```bash
readlink ~/.bashrc
readlink ~/.tmux.conf
```

Check that they point to the corresponding files inside `~/.dotfiles`.

Check that the backup files exist:

```bash
ls -la ~/.bashrc.backup* ~/.tmux.conf.backup*
```

The backup command may report that a file is missing if there was no previous configuration to back up.

## Rolling back the installation

The installer does not currently provide an automatic rollback command. You can restore the original configurations manually.

**Important:** First identify the actual backup filenames. If the default backup already existed, the installer may have created a numbered backup such as `.bashrc.backup.1`.

### 1. Restore Bash configuration

If the backup is named `.bashrc.backup`:

```bash
rm ~/.bashrc
mv ~/.bashrc.backup ~/.bashrc
```

If the backup has a numbered suffix, substitute its actual filename.

### 2. Restore Tmux configuration

If the backup is named `.tmux.conf.backup`:

```bash
rm ~/.tmux.conf
mv ~/.tmux.conf.backup ~/.tmux.conf
```

Again, use the actual numbered backup filename if necessary.

### 3. If no previous configuration existed

If the installer created a symbolic link without backing up an existing file, simply remove the link:

```bash
rm ~/.bashrc
rm ~/.tmux.conf
```

These commands remove the symbolic links, not the repository files.

### 4. Verify the rollback

```bash
ls -l ~/.bashrc ~/.tmux.conf
```

The restored files should be regular files rather than symbolic links.

## Updating the configurations

To receive changes made to the GitHub repository:

```bash
cd ~/.dotfiles
git pull
```

The symbolic links automatically expose the updated files. Reload Bash or Tmux as appropriate to apply the changes.

## Testing the installer safely

Before deploying on another machine, you can test the installer using temporary directories.

For example:

```bash
mkdir -p /tmp/dotfiles-test/home /tmp/dotfiles-test/repo

cp ~/.dotfiles/.bashrc /tmp/dotfiles-test/repo/
cp ~/.dotfiles/.tmux.conf /tmp/dotfiles-test/repo/

TARGET_HOME=/tmp/dotfiles-test/home \
DOTFILES=/tmp/dotfiles-test/repo \
bash ~/.dotfiles/install.sh
```

Inspect the resulting files:

```bash
ls -la /tmp/dotfiles-test/home
```

This allows you to test installation behaviour without modifying your actual home directory.
