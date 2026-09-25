# blackstar-only home config.

{
  pkgs,
  ...
}:

{
  imports = [
    ./home/packages.nix
    ./home/umbriel.nix
  ];
}
