{ config, lib, pkgs, ... }:

let
    assets = import ../../assets { baseSize = config.desktop.fontSize; };
    inherit (assets.fonts) roboto;

    forward_compatibility =
      if pkgs.hyprlock.version == "0.5.0"
      then backport_to_0_5_0
      else pkgs.lib.trivial.id;

    backport_to_0_5_0 = attrs:
      let inherit (lib.attrsets) attrByPath filterAttrs removeAttrs;
          cleaned = removeAttrs attrs ["auth"];
          dropNulls = filterAttrs (_: v: ! (builtins.isNull v));
          complement = {
            general = dropNulls {
              pam_module = attrByPath [ "auth" "pam" "module" ] null attrs;
              enable_fingerprint = attrByPath [ "auth" "fingerprint" "enabled" ] null attrs;
              fingerprint_ready_message = attrByPath [ "auth" "fingerprint" "ready_message" ] null attrs;
              fingerprint_present_message = attrByPath [ "auth" "fingerprint" "present_message" ] null attrs;
            };
          };
      in cleaned // complement;
in

{
  config = lib.mkIf (config.desktop.windowManager == "hyprland") {
    programs.hyprlock.enable = true;
    programs.hyprlock.settings = forward_compatibility {
      general = {
        # disable_loading_bar = true;
        grace = 10;
        # hide_cursor = false;
        # no_fade_in = false;
      };
      background = [
        {
          path = "screenshot";
          blur_passes = 3;
          blur_size = 8;
        }
      ];
      input-field = [
        {
          monitor = "";
          size = "200, 50";
          outline_thickness = 3;
          inner_color = "rgba(0, 0, 0, 0.0)"; # no fill

          dots_size = 0.2;
          dots_spacing = 0.35;

          outer_color = "rgba(33ccffee)";
          check_color = "rgba(00ff99ee)";
          fail_color = "rgba(ff6633ee)";

          # font_family = roboto.name;
          font_color = "rgb(30, 30, 30)";
          fade_on_empty = false;
          rounding = 15;

          hide_input = false;
          position = "0, -20";
          halign = "center";
          valign = "center";

          placeholder_text = "<span foreground=\"##666666\">Password…</span>";
          # shadow_passes = 2;
        }
      ];

      auth = {
        pam = {
          enabled = true;
        };
        fingerprint = {
          enabled = true;
          ready_message = "Place your right index finger on the detector";
          present_message = "Scanning the dirt...";
        };
      };

      label = [
        # time
        {
          monitor = "";
          text = "cmd[update:1000] echo \"$(date +\"%H:%M\")\"";
          color = "rgba(242, 243, 244, 0.75)";
          font_size = 95;
          font_family = roboto.name;
          position = "0, 200";
          halign = "center";
          valign = "center";
        }

        # user
        {
          monitor = "";
          text = "$DESC";
          color = "rgba(242, 243, 244, 0.75)";
          font_size = 32;
          font_family = roboto.name;
          position = "0, 80";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}
