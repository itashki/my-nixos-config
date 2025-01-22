#!/bin/bash

cp /etc/nixos/configuration.nix /tmp/configuration.nix

distrobox enter arch -- nvim /tmp/configuration.nix

sudo mv /tmp/configuration.nix /etc/nixos/configuration.nix

read -p "Do you want to rebuild the system? (yes/no): " choice

if [[ "$choice" == "yes" ]]; then
	sudo nixos-rebuild --upgrade switch
else
	echo "System rebuild cancelled."
fi
