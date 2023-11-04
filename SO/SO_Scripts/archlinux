#!/bin/bash

local programs="programs_install.in"

function base_programs {
	echo "man-db man-pages git sudo base-devel pacman-contrib networkmanager xorg-server xorg-backlight pulseaudio xorg-xinit xorg-xsetroot xlockmore xclip neovim xbindkeys picom vlc discord" > "$programs"
}

function programs_by_device
{
	local device=$(hostname)

	if [[ $1 -ne "l4Pt0p" ]] && [[ $1 -ne "D3sKt0P" ]]; then
		echo "Device $device not recogniced"
		return 1
	fi

	base_programs
	install_packages

	## Install from file
	pacman -S $(cat "$programs")

	AUR_programs $device

	return $?
}

function install_packages {

	install_shell
	install_terminal
	install_wm
	install_selector
	install_notificator
	install_imageview
	install_browser
	install_utils
	install_fonts
	install_filemanager
	install_improvements
}

function AUR_programs
{
	mkdir "aur_repos"
	cd "aur_repos"
	local source=$(pwd)
	local error=0

	# In particular of device
	if [[ $1 -eq "l4Pt0p" ]]; then
		#
	elif [[ $1 -eq "D3sKt0P" ]]; then
		#
	else
		echo "Device $1 not recogniced"
		return 1
	fi

	# In common
	if [[ $1 -eq "l4Pt0p" ]] || [[ $1 -eq "D3sKt0P" ]]; then
		## Install VSCode
		echo "Installing VSCode from AUR"
		git clone https://aur.archlinux.org/visual-studio-code-bin.git && cd visual-studio-code-bin && makepkg -s -r -i --clean
		if [[ $? != 0 ]]; then
			echo "ERROR INSTALLING VSCode CHECK TRACE"
			error=$error+1
		fi
		cd $source
	fi

	return $error
}

function update
{
	mirrors && pacman -Syyu
	local error=$?

	local device=$(hostname)

	AUR_programs $device
	error=$error + $?

	return $?
}

function install_option {
	local option_name="$1"
	local package_name="$2"

	echo "Do you want to install $option_name? (Y/n): "
	while true; do
		read choice
		choice=${choice:-Y}  # Use "Y" as default if the user presses Enter
		if [ "$choice" = "Y" ] || [ "$choice" = "y" ]; then
			echo " $package_name" >> "$programs"
		elif [ "$choice" = "N" ] || [ "$choice" = "n" ]; then
			break
		else
			echo "Invalid choice. Please enter Y or n."
		fi
	done
	echo ""
}

function install_wm
{
	echo "Choose Window Managers:"
	install_option "BSPQMbspwm" "bspwm sxhkd"
	install_option "Qtile" "qtile"
	install_option "Polybar" "polybar"
}

function install_selector
{
	echo "Choose Program Selector:"
	install_option "Rofi" "rofi"
}

function install_shell
{
	echo "Shell in use: $SHELL"
	echo "Choose Shell Selector:"
	install_option "ZSH" "zsh"
}

function install_terminal
{
	echo "Choose Terminal Selector:"
	install_option "URXVT" "rxvt-unicode"
}

function install_notificator
{

	echo "Choose Notificator Selector:"
	install_option "Dunst" "dunst"
}

function install_browser
{
	echo "Choose Browser Selector:"
	install_option "Firefox NORMAL" "firefox"
	install_option "Firefox DEV" "firefox-developer-edition"

}

function install_filemanager
{
	echo "Choose FileManager Selector:"
	install_option "Thunar" "thunar"
	install_option "Index" "index-fm"
}

function install_utils
{
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

}
function install_fonts
{
	echo "Choose Fonts:"
	install_option "Chinese/Japanese/Korean Font" "noto-fonts-cjk"
}

function install_imageview
{
	echo "Choose Image Viewer(Wallpaper setter):"
	install_option "Feh" "feh"
	install_option "Nitrogen" "nitrogen"
}

function install_improvements
{
	echo "Choose Improvements:"
	install_option "LSD" "lsd"
	install_option "DUF" "duf"
	install_option "BAT" "bat"
}

programs_by_device
exit $?
