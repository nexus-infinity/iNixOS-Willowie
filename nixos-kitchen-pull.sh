#!/bin/bash

# This script will run ON THE NIXOS MACHINE to pull and apply configuration
# Run this from Firefox on NixOS after downloading from GitHub

echo "==================================="
echo "NixOS Kitchen iMac Auto-Configuration"  
echo "==================================="

# Download the configuration from GitHub
echo "Downloading configuration from GitHub..."
curl -L https://raw.githubusercontent.com/nexus-infinity/field-living/main/nixos-imac-2019-complete.nix -o /tmp/configuration.nix

# Backup existing config
echo "Backing up existing configuration..."
sudo cp /etc/nixos/configuration.nix /etc/nixos/configuration.nix.backup.$(date +%Y%m%d_%H%M%S)

# Copy new configuration
echo "Installing new configuration..."
sudo cp /tmp/configuration.nix /etc/nixos/configuration.nix

echo ""
echo "Configuration downloaded and installed!"
echo ""
echo "Now run: sudo nixos-rebuild switch"
echo ""
echo "After rebuild, connect to WiFi with:"
echo "nmcli device wifi connect 'YOUR_WIFI_NAME' password 'YOUR_PASSWORD'"
