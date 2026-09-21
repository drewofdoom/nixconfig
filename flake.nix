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
      # GitHub-release audio plugins (see proaudio/plugins/). Auto-generated:
      # every top-level *.nix file in proaudio/plugins (except default.nix)
      # becomes a package named by its filename stem; directories with
      # default.nix (e.g. reasonus-native) are listed explicitly below.
      # Update with `nix-update <name> --flake` from the repo root
      # (multi-asset files via `python3 proaudio/plugins/update.py`).
      packages.x86_64-linux =
        let
          system = "x86_64-linux";
          callPkg = nixpkgs.legacyPackages.${system}.callPackage;
          pluginDir = ./proaudio/plugins;
          # Disabled until first stable release (upstream is prereleases-only).
          pluginFiles = builtins.filter (n: n != "default.nix" && n != "zl-spectrum-equalizer.nix") (
            builtins.attrNames (builtins.readDir pluginDir)
          );
          nixFiles = builtins.filter (n: nixpkgs.lib.hasSuffix ".nix" n) pluginFiles;
          autoPkgs = builtins.listToAttrs (
            map (f: {
              name = nixpkgs.lib.removeSuffix ".nix" f;
              value = callPkg (pluginDir + "/${f}") { };
            }) nixFiles
          );
        in
        autoPkgs
        // {
          reasonus-native = callPkg ./proaudio/reasonus-native { };
        };
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
