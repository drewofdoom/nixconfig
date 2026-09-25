# Shared packages
# Moved verbatim from configuration.nix.
{ pkgs, ... }:

let
  # TEMP (2026-09-25): xwayland-satellite 0.8.2 breaks Steam's file-picker
  # dialogs (can't Add Non-Steam Game). Upstream 0.8.3 fixes it but isn't in
  # nixpkgs (stable or unstable) yet, so build it here from the release tag.
  # NOTE: overrideAttrs does NOT work for this (stale cargoDeps — the vendor
  # hash is baked in at first evaluation), hence the fresh buildRustPackage.
  # Revert: delete this binding and use plain `xwayland-satellite` below.
  xwayland-satellite-083 = pkgs.rustPlatform.buildRustPackage {
    pname = "xwayland-satellite";
    version = "0.8.3";
    src = pkgs.fetchFromGitHub {
      owner = "Supreeeme";
      repo = "xwayland-satellite";
      tag = "v0.8.3";
      hash = "sha256-eFEjCCniMCKeWU0PcZNv+tDYe08SLFPjRplyPY8OFt4=";
    };
    cargoHash = "sha256-gMGFvnbxM3hD5fmkSimaFd87GEf6BXFe/MGjoS6VNVU=";
    postPatch = ''
      substituteInPlace resources/xwayland-satellite.service \
        --replace-fail '/usr/local/bin' "$out/bin"
    '';
    nativeBuildInputs = with pkgs; [
      installShellFiles
      makeBinaryWrapper
      pkg-config
      rustPlatform.bindgenHook
    ];
    buildInputs = with pkgs; [
      libxcb
      libxcb-cursor
    ];
    buildNoDefaultFeatures = true;
    buildFeatures = [ "systemd" ];
    outputs = [
      "out"
      "man"
    ];
    doCheck = false;
    postInstall = ''
      installManPage --name xwayland-satellite.1 xwayland-satellite.man
      install -Dm0644 resources/xwayland-satellite.service -t $out/lib/systemd/user
    '';
    postFixup = ''
      wrapProgram $out/bin/xwayland-satellite \
        --prefix PATH : "${pkgs.lib.makeBinPath [ pkgs.xwayland ]}"
    '';
    meta = {
      description = "Xwayland outside your Wayland compositor";
      homepage = "https://github.com/Supreeeme/xwayland-satellite";
      license = pkgs.lib.licenses.mpl20;
      mainProgram = "xwayland-satellite";
      platforms = pkgs.lib.platforms.linux;
    };
  };
in

{
  environment.systemPackages = with pkgs; [
    gnome-keyring
    libsecret
    vulkan-tools
    xwayland-run
    xwayland-satellite-083
  ];
}
