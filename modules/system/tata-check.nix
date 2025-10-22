{ config, lib, pkgs, ... }:

{
  # TATA Integrity Check - Confirms Sovereign Governance
  options.field.tataCheck = {
    enable = lib.mkEnableOption "Enables the TATA integrity and structural alignment check script.";
  };

  config = lib.mkIf config.field.tataCheck.enable {
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "tata-check" ''
        echo "====================================================="
        echo "🔱 TATA Integrity Check (Sovereign Governance)"
        echo "====================================================="
        echo "✅ Hostname Alignment: $(hostname)"
        echo "✅ Current Time (Temporal Anchor): $(date)"
        echo "✅ Structural Root Path: $(pwd)"
        if [[ "$(pwd)" == "/etc/nixos/iNixOS-Willowie" ]]; then
          echo "✅ SOVEREIGN GOVERNANCE: SUCCESS. Canonical Root is correct."
        else
          echo "❌ SOVEREIGN GOVERNANCE: FAILURE. Must be executed from /etc/nixos/iNixOS-Willowie"
        fi
        echo "====================================================="
      '')
    ];
  };
}
