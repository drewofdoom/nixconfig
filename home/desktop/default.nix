# Compositor user settings (Umbriel + Noctalia shell).
{ ... }:

{
  imports = [
    ./umbriel.nix
    ./noctalia.nix
    ./screen-record.nix
  ];
}
