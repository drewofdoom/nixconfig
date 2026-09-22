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
      # Local packages. Auto-generated: every top-level *.nix file in
      # proaudio/plugins/ and pkgs/ becomes a package named by its filename
      # stem (minus default.nix and the disabled zl-spectrum-equalizer);
      # directories with default.nix (e.g. reasonus-native) are explicit below.
      # Plugin updates: `python3 proaudio/plugins/update.py --all` from the
      # repo root. Handles both single-asset and multi-asset files, including
      # monorepo tag prefixes (see `# update-tag-prefix:` directives).
      packages.x86_64-linux =
        let
          system = "x86_64-linux";
          callPkg = nixpkgs.legacyPackages.${system}.callPackage;
          autoDir =
            dir: excludes:
            let
              files = builtins.filter (n: !(builtins.elem n excludes)) (
                builtins.attrNames (builtins.readDir dir)
              );
              nixFiles = builtins.filter (n: nixpkgs.lib.hasSuffix ".nix" n) files;
            in
            builtins.listToAttrs (
              map (f: {
                name = nixpkgs.lib.removeSuffix ".nix" f;
                value = callPkg (dir + "/${f}") { };
              }) nixFiles
            );
        in
        autoDir ./proaudio/plugins [
          "default.nix"
          "zl-spectrum-equalizer.nix"
        ]
        // autoDir ./pkgs [ "default.nix" ]
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

  nixConfig = { };
}
