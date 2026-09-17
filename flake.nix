{
  description = "NixOS - Umbriel + Noctalia desktop for drew";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

    home-manager = {
      url = "github:nix-community/home-manager";
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
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations =
      let
        mkHost = hostName: nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./configuration.nix
            ./hosts/${hostName}/host.nix
            ./hosts/${hostName}/hardware-configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.drew = {
                imports = [ ./home-common.nix ./hosts/${hostName}/home.nix ];
              };
            }
          ];
        };
      in
      {
        shephard = mkHost "shephard";
        # blackstar = mkHost "blackstar"; # needs hosts/blackstar/hardware-configuration.nix first
      };
  };

  nixConfig = {
    extra-substituters = [
      "https://noctalia.cachix.org"
      "https://pipewirecontroller-nix.cachix.org"
    ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      "pipewirecontroller-nix.cachix.org-1:wY/tr9Hxc0kvGW2zgh2DUjQI+LqLBCQ7bm9Wkr3dgdc="
    ];
  };
}
