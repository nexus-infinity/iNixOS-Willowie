# Vishuddha Desktop Environment
# Sway compositor with sacred geometry layouts
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.vishuddhDesktop;
in
{
  options.services.vishuddhDesktop = {
    enable = mkEnableOption "Vishuddha desktop environment with Sway";

    user = mkOption {
      type = types.str;
      default = "willowie";
      description = "User for desktop environment";
    };

    waybarChakraDisplay = mkOption {
      type = types.bool;
      default = true;
      description = "Show chakra states in Waybar";
    };
  };

  config = mkIf cfg.enable {
    # Enable Wayland and Sway
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      extraPackages = with pkgs; [
        swaylock
        swayidle
        wl-clipboard
        mako
        dmenu
        waybar
        foot
      ];
    };

    # XDG portal for screen sharing, etc.
    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };

    # Sway configuration with sacred geometry workspaces
    environment.etc."sway/config.d/chakra-workspaces.conf".text = ''
      # Sacred Geometry Workspace Layout
      # 7 Chakras + 2 Meta spaces = 9 total
      
      set $ws1 "1:● Muladhara (Root)"
      set $ws2 "2:◐ Svadhisthana (Sacral)"
      set $ws3 "3:◑ Manipura (Solar)"
      set $ws4 "4:◒ Anahata (Heart)"
      set $ws5 "5:◓ Vishuddha (Throat)"
      set $ws6 "6:◔ Ajna (Third Eye)"
      set $ws7 "7:○ Sahasrara (Crown)"
      set $ws8 "8:◈ Soma (Manifestation)"
      set $ws9 "9:◉ Jnana (Knowledge)"
      
      # Workspace bindings
      bindsym $mod+1 workspace $ws1
      bindsym $mod+2 workspace $ws2
      bindsym $mod+3 workspace $ws3
      bindsym $mod+4 workspace $ws4
      bindsym $mod+5 workspace $ws5
      bindsym $mod+6 workspace $ws6
      bindsym $mod+7 workspace $ws7
      bindsym $mod+8 workspace $ws8
      bindsym $mod+9 workspace $ws9
      
      # Move windows to workspaces
      bindsym $mod+Shift+1 move container to workspace $ws1
      bindsym $mod+Shift+2 move container to workspace $ws2
      bindsym $mod+Shift+3 move container to workspace $ws3
      bindsym $mod+Shift+4 move container to workspace $ws4
      bindsym $mod+Shift+5 move container to workspace $ws5
      bindsym $mod+Shift+6 move container to workspace $ws6
      bindsym $mod+Shift+7 move container to workspace $ws7
      bindsym $mod+Shift+8 move container to workspace $ws8
      bindsym $mod+Shift+9 move container to workspace $ws9
      
      # Bumble bee visualization shortcut
      bindsym $mod+b exec bumble-bee-visualizer
    '';

    # Waybar configuration with chakra states
    environment.etc."xdg/waybar/config".text = builtins.toJSON {
      layer = "top";
      position = "top";
      height = 30;
      modules-left = [ "sway/workspaces" "sway/mode" ];
      modules-center = [ "clock" ];
      modules-right = [ "custom/chakra-status" "pulseaudio" "network" "battery" ];
      
      "custom/chakra-status" = {
        exec = "curl -s localhost:6001/health | jq -r '.state' || echo 'offline'";
        interval = 30;
        format = "◉ Ajna: {}";
      };
      
      clock = {
        format = "{:%Y-%m-%d %H:%M:%S}";
        interval = 1;
      };
    };

    # Ensure user exists
    users.users.${cfg.user} = {
      isNormalUser = true;
      extraGroups = [ "wheel" "video" "audio" ];
    };
  };
}
