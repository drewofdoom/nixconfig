# Shared system config: NixOS modules for all hosts.
# Imported by flake.nix mkHost (replaces configuration.nix).
{ ... }:

{
  imports = [
    ./core.nix
    ./desktop.nix
    ./hardware.nix
    ./services.nix
    ./packages.nix
    # NOTE: no ./nvidia.nix here -- it's opt-in per host
    # (hosts/blackstar/host.nix). shephard is Intel-only.
  ];
}
