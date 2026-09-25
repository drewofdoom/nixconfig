# blackstar-only home config.

{
  pkgs,
  ...
}:

{
  imports = [
    ./home/packages.nix
    ./home/gaming.nix
    ./home/umbriel.nix
  ];
}
