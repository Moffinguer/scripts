#!/bin/bash

local route="./SO_SCRIPTS"

case "$OSTYPE" in
	*"linux-gnu"*)
		local distro=$(cat /etc/os-release | grep -ie "^NAME=" | awk -F '=' '{gsub(/"/, "", $2); print $2}')
		case "$distro" in
			*"Arch Linux"*)
				echo "ArchLinux Distro Detected"
				"$route"/archlinux.sh
				;;
				*"Debian"*)
				echo "Debian Distro Detected"
						"$route"/debian.sh
						;;
				*"Gentoo"*)
				#echo "Gentoo Distro Detected"
						"$route"/gentoo.sh
						;;
			*)
				echo "Cannot load packages for $distro"
				exit 1
				;;
		esac
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
