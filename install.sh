#!/usr/bin/env bash

TARGET_HOME="${TARGET_HOME:-$HOME}"
DOTFILES="${DOTFILES:-$TARGET_HOME/.dotfiles}"

if [ ! -d "$TARGET_HOME" ]; then
	echo "Error: Target home directory does not exist: $TARGET_HOME" >&2
	exit 1
fi

install_config() {
	if [ "$#" -ne 1 ]; then
		echo "Usage: install_config FILENAME" >&2
		return 2
	fi

	local filename="$1"
	local source="$DOTFILES/$filename"
	local destination="$TARGET_HOME/$filename"

	if [ ! -f "$source" ]; then
		echo "Error: Source does not exist: $source" >&2
		return 1
	fi

	if [ -L "$destination" ]; then
		if [ "$(realpath "$destination")" = "$(realpath "$source")" ]; then
			echo "$filename is already linked."
		else
			echo "Warning: $filename is linked elsewhere. Skipping." >&2
		fi
		return 0
	fi

	if [ -f "$destination" ]; then
		local backup="$destination.backup"
		local counter=1

		while [ -e "$backup" ] || [ -L "$backup" ]; do
			backup="$destination.backup.$counter"
			(( counter += 1 ))
		done

		if cp "$destination" "$backup"; then
			echo "Backup created at: $backup"
		else
			echo "Error: Backup failed. Aborting installation." >&2
			return 1
		fi

		if rm "$destination"; then
			if create_link "$source" "$destination"; then
				echo "$filename backed up and linked."
			else
				echo "Installation failed." >&2
				return 1
			fi
		else
			echo "Failed to remove $destination." >&2
			return 1
		fi

	elif [ -e "$destination" ]; then
		echo "Error: $destination exists but is not a regular file or symlink." >&2
		return 1

	else
		if create_link "$source" "$destination"; then
			echo "$filename linked."
		else
			echo "Installation failed." >&2
			return 1
		fi
	fi
}

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

installation_failed=0

if install_config ".bashrc"; then
	echo ".bashrc installation successful."
else
	installation_failed=1
fi

if install_config ".tmux.conf"; then
	echo ".tmux.conf installation successful."
else
	installation_failed=1
fi

if [ "$installation_failed" -eq 1 ]; then
	exit 1
else
	exit 0
fi

