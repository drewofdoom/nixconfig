# blackstar-specific settings.
# NOTE: not wired into flake.nix yet -- drop in the hardware-configuration.nix
# generated on that machine (nixos-generate-config), then add
#   blackstar = mkHost "blackstar";
# to nixosConfigurations.
{ ... }:

{
  imports = [ ../../modules/nvidia.nix ];

  networking.hostName = "blackstar";

  # Steam needs its FHS env, udev rules (controllers) and firewall ports --
  # the package alone won't work.
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };
  programs.gamemode.enable = true;
}
