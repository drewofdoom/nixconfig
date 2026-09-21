# Conflux icon theme (not in nixpkgs yet):
# https://github.com/MoshiurRahmanAdib/Conflux-Icon-Theme
# Repo root IS the theme dir (index.theme at top level). Pinned to a commit;
# re-pin once upstream tags a release.
{
  lib,
  stdenvNoCC,
  fetchzip,
}:

stdenvNoCC.mkDerivation {
  pname = "conflux-icon-theme";
  version = "2026-09-21-d64da34";

  src = fetchzip {
    url = "https://github.com/MoshiurRahmanAdib/Conflux-Icon-Theme/archive/d64da34e6e81dd9a08ca068d55038b0578b1ba98.tar.gz";
    hash = "sha256-jmm+k7S1w02iEbUhviyKViBxbdJFnusvSKVA6hA1l0A=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/icons/Conflux
    # Theme payload only -- skip Workspace sources, CI metadata, and docs.
    cp -r --no-preserve=mode "$src"/. $out/share/icons/Conflux/
    rm -rf $out/share/icons/Conflux/{Workspace,.github,CONTRIBUTING.md,CREDITS.md,README.md,preview.png,before-after-1.png,.gitignore}
    # Upstream is young: some symlinks point at icons that don't exist yet.
    # Prune them (Inherits=Adwaita,hicolor covers the gaps) so the
    # noBrokenSymlinks hook passes.
    find $out/share/icons/Conflux -xtype l -delete
    runHook postInstall
  '';

  meta = with lib; {
    description = "Beautiful, modern, and neutral Linux icon theme";
    homepage = "https://github.com/MoshiurRahmanAdib/Conflux-Icon-Theme";
    license = licenses.gpl3Only;
    platforms = platforms.all;
  };
}
