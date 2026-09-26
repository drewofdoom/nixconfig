# blackstar-only home config.

{ ... }:

{
  imports = [
    ./backup.nix
    ./home/packages.nix
    ./home/gaming.nix
    ./home/umbriel.nix
  ];
}
