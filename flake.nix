{
  description = "NixOS - Umbriel + Noctalia desktop for drew";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Noctalia v5 (native, not Quickshell) - cachix branch = latest cached build
    noctalia.url = "github:noctalia-dev/noctalia/cachix";

    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    umbriel = {
      url = "github:noctalia-dev/umbriel";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pipewirecontroller = {
      url = "github:ArisoN-ext/PipeWireController-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Declarative REAPER packaging + Home Manager config. Ships REAPER, SWS,
    # a patched ReaPack (managed-package API), themes, and the experimental
    # native-Wayland SWELL library. See proaudio/default.nix.
    reaper-flake = {
      url = "github:9Prestidigitator/reaper-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    {
      nixosConfigurations =
        let
          mkHost =
            hostName:
            nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              specialArgs = { inherit inputs; };
              modules = [
                ./system
                ./hosts/${hostName}/host.nix
                ./hosts/${hostName}/hardware-configuration.nix
                home-manager.nixosModules.home-manager
                {
                  home-manager.useGlobalPkgs = true;
                  home-manager.useUserPackages = true;
                  home-manager.backupFileExtension = "backup";
                  home-manager.extraSpecialArgs = { inherit inputs; };
                  home-manager.users.drew = {
                    imports = [
                      ./home
                      ./hosts/${hostName}/home.nix
                    ];
                  };
                }
              ];
            };
        in
        {
          shephard = mkHost "shephard";
          blackstar = mkHost "blackstar";
        };
    };

  nixConfig = { };
}
