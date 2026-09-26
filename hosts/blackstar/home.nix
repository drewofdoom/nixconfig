# blackstar-only home config.

{
  pkgs,
  ...
}:

{
  imports = [
    ./backup.nix
    ./home/packages.nix
    ./home/gaming.nix
    ./home/umbriel.nix
  ];
}
