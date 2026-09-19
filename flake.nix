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
      # GitHub-release audio plugins (see proaudio/plugins/). One line per
      # plugin; update with `nix-update <name> --flake` from the repo root.
      packages.x86_64-linux = {
        zl-equalizer =
          nixpkgs.legacyPackages.x86_64-linux.callPackage ./proaudio/plugins/zl-equalizer.nix
            { };
        zl-splitter =
          nixpkgs.legacyPackages.x86_64-linux.callPackage ./proaudio/plugins/zl-splitter.nix
            { };
        # Disabled until first stable release (upstream is prereleases-only):
        # zl-spectrum-equalizer = nixpkgs.legacyPackages.x86_64-linux.callPackage ./proaudio/plugins/zl-spectrum-equalizer.nix { };
        zl-compressor =
          nixpkgs.legacyPackages.x86_64-linux.callPackage ./proaudio/plugins/zl-compressor.nix
            { };
        dusk-4k-eq = nixpkgs.legacyPackages.x86_64-linux.callPackage ./proaudio/plugins/dusk-4k-eq.nix { };
        dusk-4k-eq-2 =
          nixpkgs.legacyPackages.x86_64-linux.callPackage ./proaudio/plugins/dusk-4k-eq-2.nix
            { };
        dusk-chord-analyzer =
          nixpkgs.legacyPackages.x86_64-linux.callPackage ./proaudio/plugins/dusk-chord-analyzer.nix
            { };
        duskverb = nixpkgs.legacyPackages.x86_64-linux.callPackage ./proaudio/plugins/duskverb.nix { };
        dusk-multi-comp =
          nixpkgs.legacyPackages.x86_64-linux.callPackage ./proaudio/plugins/dusk-multi-comp.nix
            { };
        dusk-multi-q =
          nixpkgs.legacyPackages.x86_64-linux.callPackage ./proaudio/plugins/dusk-multi-q.nix
            { };
        dusk-spectrum-analyzer =
          nixpkgs.legacyPackages.x86_64-linux.callPackage ./proaudio/plugins/dusk-spectrum-analyzer.nix
            { };
        dusk-sunset-circuits =
          nixpkgs.legacyPackages.x86_64-linux.callPackage ./proaudio/plugins/dusk-sunset-circuits.nix
            { };
        dusk-tape-echo-2 =
          nixpkgs.legacyPackages.x86_64-linux.callPackage ./proaudio/plugins/dusk-tape-echo-2.nix
            { };
        dusk-tapemachine =
          nixpkgs.legacyPackages.x86_64-linux.callPackage ./proaudio/plugins/dusk-tapemachine.nix
            { };
        dusk-tapemachine-2 =
          nixpkgs.legacyPackages.x86_64-linux.callPackage ./proaudio/plugins/dusk-tapemachine-2.nix
            { };
        brummer-loopino =
          nixpkgs.legacyPackages.x86_64-linux.callPackage ./proaudio/plugins/brummer-loopino.nix
            { };
        brummer-toneshifteq =
          nixpkgs.legacyPackages.x86_64-linux.callPackage ./proaudio/plugins/brummer-toneshifteq.nix
            { };
        brummer-neuralrack =
          nixpkgs.legacyPackages.x86_64-linux.callPackage ./proaudio/plugins/brummer-neuralrack.nix
            { };
        brummer-loadbox =
          nixpkgs.legacyPackages.x86_64-linux.callPackage ./proaudio/plugins/brummer-loadbox.nix
            { };
        brummer-smoothir =
          nixpkgs.legacyPackages.x86_64-linux.callPackage ./proaudio/plugins/brummer-smoothir.nix
            { };
        ross-vu = nixpkgs.legacyPackages.x86_64-linux.callPackage ./proaudio/plugins/ross-vu.nix { };
        reasonus-native = nixpkgs.legacyPackages.x86_64-linux.callPackage ./proaudio/reasonus-native { };
      };
      nixosConfigurations =
        let
          mkHost =
            hostName:
            nixpkgs.lib.nixosSystem {
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
                  home-manager.backupFileExtension = "backup";
                  home-manager.extraSpecialArgs = { inherit inputs; };
                  home-manager.users.drew = {
                    imports = [
                      ./home-common.nix
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
