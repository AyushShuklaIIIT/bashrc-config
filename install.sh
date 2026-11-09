#!/usr/bin/env bash

TARGET_HOME="${TARGET_HOME:-$HOME}"
DOTFILES="${DOTFILES:-$TARGET_HOME/.dotfiles}"

if [ ! -d "$TARGET_HOME" ]; then
	echo "Error: Target home directory does not exist: $TARGET_HOME" >&2
	exit 1
fi

create_link() {
	if [ "$#" -ne 2 ]; then
		echo "Usage: create_link SOURCE DESTINATION" >&2
		return 2
	fi

	local source="$1"
	local destination="$2"

	if [ ! -e "$source" ]; then
		echo "Error: Source does not exist: $source" >&2
		return 1
	fi

	if ln -s "$source" "$destination"; then
        	echo "Link created successfully."
	else
        	echo "Failed to create link." >&2
        	return 1
	fi
}

if [ ! -f "$DOTFILES/.bashrc" ]; then
	echo "Error: .bashrc not found in dotfiles repository." >&2
	exit 1
fi

if [ -L "$TARGET_HOME/.bashrc" ]; then
	if [ "$(realpath "$TARGET_HOME/.bashrc")" = "$(realpath "$DOTFILES/.bashrc")" ]; then
		echo ".bashrc is already linked."
	else
		echo "Warning: .bashrc is linked elsewhere. Skipping."
	fi

elif [ -f "$TARGET_HOME/.bashrc" ]; then
	backup="$TARGET_HOME/.bashrc.backup"
	counter=1

	while [ -e "$backup" ] || [ -L "$backup" ]; do
		backup="$TARGET_HOME/.bashrc.backup.$counter"
		(( counter += 1 ))
	done

	if cp "$TARGET_HOME/.bashrc" "$backup"; then
		echo "Backup created at: $backup"
	else
		echo "Error: Backup failed. Aborting installation."
		exit 1
	fi

	if rm "$TARGET_HOME/.bashrc"; then
		if create_link "$DOTFILES/.bashrc" "$TARGET_HOME/.bashrc"; then
                	echo ".bashrc backed up and linked."
        	else
                	echo "Installation failed." >&2
                	exit 1
        	fi
	else
		echo "Failed to remove $TARGET_HOME/.bashrc" >&2
		exit 1
	fi

elif [ -e "$TARGET_HOME/.bashrc" ]; then
	echo "Error: $TARGET_HOME/.bashrc exists but is not a regular file or symlink." >&2
	exit 1

else
	if create_link "$DOTFILES/.bashrc" "$TARGET_HOME/.bashrc"; then
		echo ".bashrc linked."
	else
		echo "Installation failed." >&2
		exit 1
	fi
fi
