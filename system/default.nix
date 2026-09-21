# Shared system config: NixOS modules for all hosts.
# Imported by flake.nix mkHost (replaces configuration.nix).
{ ... }:

{
  imports = [
    ./core.nix
    ./desktop.nix
    ./hardware.nix
    ./services.nix
    ./nvidia.nix
  ];
}
