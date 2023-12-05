#!/bin/bash

local route="./scripts"

case "$OSTYPE" in
	*"linux-gnu"*)
		local distro=$(cat /etc/os-release | grep -ie "^NAME=" | awk -F '=' '{gsub(/"/, "", $2); print $2}')
		case "$distro" in
			*"Arch"*)
				echo "ArchLinux Distro Detected"
				local argument="arch"
				;;
			*"Debian"*)
				echo "Debian Distro Detected"
				local argument="debian"
				;;
			*"Gentoo"*)
				echo "Gentoo Distro Detected"
				local argument="gentoo"
				;;
			*)
				echo "Cannot load packages for $distro"
				exit 1
				;;
		esac
		"$route"/unix.sh "$argument"
		;;
	*"darwin"*)
		echo "MacOS System Detected"
		"$route"/macos.sh
		;;
	*"msys"* | *"cygwin"*)
		echo "Windows System Detected"
		powershell.exe -ExecutionPolicy Bypass "$route"/windows.ps1
		;;
	*)
		echo "SO Not detected"
		exit 1
		;;
esac

if [[ $? != 0 ]]; then
	echo "Error installing packages for system"
	exit 1
fi

echo ""; echo ""
echo "Configuration Succesfull"
echo ""; echo ""

exit 0
