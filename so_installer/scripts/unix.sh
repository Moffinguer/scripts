#!/bin/bash

local list_programs=""

function base_programs #( device )
{
	## Manuals( common )
	list_programs="$list_programs man-db man-pages "

	## Default programs( common )
	list_programs="$list_programs git base-devel sudo neovim "

	## Pacman Utils( common )
	list_programs="$list_programs pacman-contrib "

	## Network( common )
	list_programs="$list_programs networkmanager " # consider iws

	## Xorg( common )
	list_programs="$list_programs xorg-server xorg-backlight xorg-xinit xorg-xsetroot xlockmore xclip xbindkeys picom "

	## Sound( common )
	list_programs="$list_programs pulseaudio " # consider pipewire

	## Misc Utils( common )
	list_programs="$list_programs vlc discord "

	case "$1" in
		l4Pt0p)
			# Multiple Screens
			list_programs="$list_programs arandr "
			;;
		D3sKt0P)
			# Multiple Screens
			list_programs="$list_programs xorg-xrandr " # consider using arandr directly
			;;
		*)
			echo "Device $1 not recogniced"
			exit 1
			;;
	esac
}

function install_packages {

	## install_shell
	echo "Shell in use: $SHELL"
	echo "Choose Shell Selector:"
	install_option "ZSH" "zsh"

	## install_terminal
	echo "Choose Terminal Selector:"
	install_option "URXVT" "rxvt-unicode"

	## install_wm
	echo "Choose Window Managers:"
	install_option "BSWQM" "bspwm sxhkd"
	install_option "Qtile" "qtile"
	install_option "Polybar" "polybar"

	## install_selector
	echo "Choose Program Selector:"
	install_option "Rofi" "rofi"

	## install_notificator
	echo "Choose Notificator Selector:"
	install_option "Dunst" "dunst"

	## install_imageview
	echo "Choose Image Viewer(Wallpaper setter):"
	install_option "Feh" "feh"
	install_option "Nitrogen" "nitrogen"

	## install_browser
	echo "Choose Browser Selector:"
	install_option "Firefox NORMAL" "firefox"
	install_option "Firefox DEV" "firefox-developer-edition"

	## install_utils
	echo "Choose Utils Selector:"
	echo "AutoMonter->"
	install_option "UDiskie" "udiskie"
	echo "Sreenshooter->"
	install_option "flameshot" "flameshot"
	echo "Administration->"
	install_option "NetworkUtils BIND" "bind"
	install_option "Wireshark" "wireshark-qt"
	install_option "Docker" "docker"
	install_option "Podman" "podman"
	install_option "BTop" "btop"
	install_option "Gimp" "gimp"

	## install_fonts
	echo "Choose Fonts:"
	install_option "Chinese/Japanese/Korean Symbols" "noto-fonts-cjk"
	install_option "Emoji Symbols" "noto-fonts-emoji"
	install_option "Noto Font" "noto-fonts"
	install_option "FiraCode" "ttf-fira-code"
	install_option "Terminess" "ttf-terminus-nerd"
	install_option "JetBrains Nerd" "ttf-jetbrains-mono-nerd"
	echo "For special fonts look at \'fonts\' folder"
	install_option "Monocraft" "a" "font"

	## install_filemanager
	echo "Choose FileManager Selector:"
	install_option "Thunar" "thunar"
	install_option "Index" "index-fm"

	## install_improvements
	echo "Choose Improvements:"
	install_option "LSD" "lsd"
	install_option "DUF" "duf"
	install_option "BAT" "bat"

}

function install_option {
	local option_name="$1"
	local package_name="$2"
	local install_type="$3"

	echo "Do you want to install $option_name? (Y/n): "
	while true; do
		read choice
		choice=${choice:-Y}
		if [ "$choice" = "Y" ] || [ "$choice" = "y" ]; then
			if [ "$install_type" != "font" ]; then
				list_programs="$list_programs $package_name " &
			else
				case "$option_name" in
					Monocraft)
						curl -s -O https://github.com/IdreesInc/Monocraft/releases/latest/download/Monocraft-nerd-fonts-patched.ttf && mkdir -p fonts/Monocraft && mv Monocraft-nerd-fonts-patched.ttf fonts/Monocraft/Monocraft-nerd-fonts-patched.ttf &
						;;
					*)
						echo "Undetected font $option_name"
						;;
				esac
			fi
			break
		elif [ "$choice" = "N" ] || [ "$choice" = "n" ]; then
			break
		else
			echo "Invalid choice. Please enter Y or n."
		fi
	done
	echo ""
}

if ! ping -q -c 1 -W 1 google.com >/dev/null; then
	echo "No internet connection, cannot download"
	exit 1
fi

local distro=$1
local device=$(hostname)

if [[ $distro -eq "arch" ]] ; then
	[[ $device -ne "l4Pt0p" ]] && [[ $device -ne "D3sKt0P" ]] && echo "Device $device not recogniced" && exit 1
	
	local error=0

	base_programs "$device"
	install_packages "$device"
	## Drivers
	## Gaming

	## Install from file
	pacman -S "$list_programs"
	error=$?
fi

exit $error

