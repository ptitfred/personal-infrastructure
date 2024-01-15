# This is the configuration required to run NixOS on GandiCloud.
{ lib, modulesPath, ... }:
{
  imports = [
    "${toString modulesPath}/../maintainers/scripts/openstack/openstack-image.nix"
  ];

  config = {
    boot.initrd.kernelModules = [
      "xen-blkfront" "xen-tpmfront" "xen-kbdfront" "xen-fbfront"
      "xen-netfront" "xen-pcifront" "xen-scsifront"
    ];
    # This is to get a prompt via the "openstack console url show" command
    systemd.services."getty@tty1" = {
      enable = lib.mkForce true;
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Restart = "always";
    };

    # This is required since 23.11 ; I'm not sure why. Maybe Gandi changed something in their VMs.
    boot.loader.grub.device = lib.mkForce "nodev";
  };
}
