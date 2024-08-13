#!/bin/sh

# variables
alwaysrename=0
alwaysdelete=0
alwaysskip=0

# functions
copy_with_confirmation() {
	if [ -e $2 ]; then
		if [ $alwaysrename -eq 1 ]; then
			echo "renaming '$2' to '$2-bak'"
			mv "$2" "$2-bak"
			cp -r "$1" "$2"
		elif [ $alwaysdelete -eq 1 ]; then
			echo "deleting file/directory '$2'"
			rm -rf "$2"
			cp -r "$1" "$2"
		elif [ $alwaysskip -eq 1 ]; then
			echo "skipping file/directory '$2'"
		else
			echo "the file/directory $2' already exists, do you want to:"
			echo "1. [R]ename the original to '$2-bak'"
			echo "2. Always [re]name, don't ask me again"
			echo "3. [D]elete the original PERMAMENTLY and replace it"
			echo "4. Always [de]lete, don't ask me again"
			echo "5. [S]kip this file/directory"
			echo "6. Always [sk]ip, don't ask me again"
			printf "enter your choice: "
			read answer
			while true; do
				if [ "$(echo $answer | tr '[:upper:]' '[:lower:]')" = "r" ]; then
					# rename
					echo "renaming '$2' to '$2-bak'"
					mv "$2" "$2-bak"
					cp -r "$1" "$2"
					break
				elif [ "$(echo $answer | tr '[:upper:]' '[:lower:]')" = "re" ]; then
					# always rename
					alwaysrename=1
					echo "renaming '$2' to '$2-bak'"
					mv "$2" "$2-bak"
					cp -r "$1" "$2"
					break
				elif [ "$(echo $answer | tr '[:upper:]' '[:lower:]')" = "d" ]; then
					# delete
					echo "deleting file/directory '$2'"
					rm -rf "$2"
					cp -r "$1" "$2"
					break
				elif [ "$(echo $answer | tr '[:upper:]' '[:lower:]')" = "de" ]; then
					# always delete
					alwaysdelete=1
					echo "deleting file/directory '$2'"
					rm -rf "$2"
					cp -r "$1" "$2"
					break
				elif [ "$(echo $answer | tr '[:upper:]' '[:lower:]')" = "s" ]; then
					# skip
					echo "skipping file/directory '$2'"
					break
				elif [ "$(echo $answer | tr '[:upper:]' '[:lower:]')" = "sk" ]; then
					# always skip
					alwaysskip=1
					echo "skipping file/directory '$2'"
					break
				fi
				echo "invalid answer: $answer"
			done
		fi
	else
		cp -r "$1" "$2"
	fi
}

maybe_mkdir() {
	if [ ! -d $1 ]; then
		echo "the directory $1 doesn't exist - creating it"
		if ! mkdir -p "$1"; then
			echo "mkdir $1 failed -- exiting" >&2
			exit 1
		fi
	fi
}

# apps that are used by these dotfiles
somemissing=0
echo "these apps are used by these dotfiles:"
for app in sway swaybg alacritty zsh waybar; do
	if which "$app" > /dev/null 2>&1; then
		# print in green
		printf ' \033[32m%s' "$app"
	else
		# print in red
		somemissing=1
		printf ' \033[31m%s' "$app"
	fi
done

printf "\033[0m\nthese apps are also used in the dotfiles but can be easily replaced/removed in the configs:\n"
for app in sway-launcher-desktop bashmount lf slurp grim wl-copy fzf zoxide; do
	if which "$app" > /dev/null 2>&1; then
		# print in green
		printf ' \033[32m%s' "$app"
	else
		# print in red
		somemissing=1
		printf ' \033[31m%s' "$app"
	fi
done

# apps that arent used by these dotfiles but have provided configs
printf "\033[0m\nthese apps are not used by these dotfiles but have provided configs for them in the dotfiles:\n"
for app in bat nvim; do
	if which "$app" > /dev/null 2>&1; then
		# print in green
		printf ' \033[32m%s' "$app"
	else
		# print in red
		somemissing=1
		printf ' \033[31m%s' "$app"
	fi
done
printf "\033[0m\n\n(\033[32mgreen\033[0m = installed, \033[31mred\033[0m = not installed)\n\n"
printf "you'll also need oh-my-zsh (https://ohmyz.sh/) (optionally with the zsh-autosuggestions plugin) and the JetBrains Mono nerd fonts.\nif you want the Neovim config to work properly, you'll also need vim-plug.\n\n"

if [ $somemissing -eq 1 ]; then
	if which pacman > /dev/null 2>&1; then
		missing=""
		echo "it looks like you're using Arch (or another pacman-based distro)."
		echo "you'll need to install these packages:"
		for pkg in sway swaybg alacritty zsh waybar lf slurp grim wl-clipboard fzf ttf-jetbrains-mono-nerd bat neovim; do
			if ! pacman -Qi "$pkg" > /dev/null 2>&1; then
				missing="$missing $pkg"
			fi
		done
		echo "$missing"
		echo "you'll need to install these AUR packages:"
		missing=""
		for aurpkg in bashmount sway-launcher-desktop; do
			if ! pacman -Qi "$aurpkg" > /dev/null 2>&1; then
				missing="$missing $aurpkg"
			fi
		done
		echo "$missing"
		echo "and you'll need to install oh-my-zsh (+ optionally zsh-autosuggestions) as well."
	elif which xbps-install > /dev/null 2>&1; then
		missing=""
		echo "it looks like you're using Void."
		echo "you'll need to install these packages:"
		for pkg in sway swaybg alacritty zsh Waybar lf slurp grim wl-clipboard fzf bat neovim; do
			if ! xbps-query -i "$pkg" > /dev/null 2>&1; then
				missing="$missing $pkg"
			fi
		done
		echo "$missing"
		echo "and you'll need to install the rest manually."
	fi
fi

printf "begin the installation? [y/N] "
read answer
if [ "$answer" != "${answer#[Yy]}" ]; then
	if ! which git > /dev/null 2>&1; then
		echo "it looks like you don't have git installed, which is needed to clone the dotfiles repo." >&2
		exit 1
	fi

	# clone the repo
	if ! git clone --depth=1 https://github.com/iusevoidbtw/dotfiles.git; then
		echo "cloning git repo failed -- exiting" >&2
		exit 1
	fi

	# copy over stuff from .config
	maybe_mkdir ~/.config

	for confdir in `ls dotfiles/.config`; do
		copy_with_confirmation dotfiles/.config/$confdir ~/.config/$confdir
	done

	# copy over stuff from .local/bin
	maybe_mkdir ~/.local/bin

	for script in `ls dotfiles/.local/bin`; do
		copy_with_confirmation dotfiles/.local/bin/$script ~/.local/bin/$script
	done

	# copy over stuff from .local/share/wallpapers
	maybe_mkdir ~/.local/share/wallpapers

	for wallpaper in `ls dotfiles/.local/share/wallpapers`; do
		copy_with_confirmation dotfiles/.local/share/wallpapers/$wallpaper ~/.local/share/wallpapers/$wallpaper
	done

	# copy over stuff from .oh-my-zsh
	maybe_mkdir ~/.oh-my-zsh/custom
	copy_with_confirmation dotfiles/.oh-my-zsh/custom/aliases.zsh ~/.oh-my-zsh/custom/aliases.zsh

	# copy over stuff from home directory
	copy_with_confirmation dotfiles/.profile .profile
	copy_with_confirmation dotfiles/.zshrc .zshrc

	ln -s .profile .zsh_profile

	echo "done! you should log out and log back in for some changes to apply."
else
	echo "exiting."
fi
