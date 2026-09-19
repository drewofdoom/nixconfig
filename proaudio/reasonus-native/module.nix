# Links the ReaSonus Native extension into REAPER's resource directory.
#
# REAPER only loads extensions from its own resource path, so the built
# artifacts have to be placed there:
#   <resource>/UserPlugins/reaper_ReasonusNative-x86_64.so
#   <resource>/UserPlugins/ReaSonus/en-US.ini
#
# The .so is symlinked straight from the store (REAPER only reads it).
#
# en-US.ini is *copied* rather than symlinked. At startup the extension does
# `std::filesystem::copy(UserPlugins/ReaSonus/en-US.ini,
# ReaSonus/Locales/en-US.ini, overwrite_existing)` and then writes back to the
# destination. A store symlink is read-only, and std::filesystem::copy refuses
# to overwrite a read-only destination ("Permission denied"), so the file has
# to be a regular writable file. Copying it on activation also means the
# extension can freely rewrite it without fighting the store.
{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.programs.reaper;
  reasonus = pkgs.callPackage ./. { };

  # configPath is an absolute path under $HOME (e.g. ~/.config/reaper-flake);
  # xdg.configFile wants it relative to ~/.config.
  resourceDir = lib.removePrefix "${config.xdg.configHome}/" cfg.configPath;
in
{
  xdg.configFile."${resourceDir}/UserPlugins/reaper_ReasonusNative-x86_64.so".source =
    "${reasonus}/UserPlugins/reaper_ReasonusNative-x86_64.so";

  # Seed the locale file as a writable copy. The extension may rewrite it at
  # runtime, so it is re-seeded only when the packaged content differs.
  home.activation.reasonusLocales = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    locale_dir="${cfg.configPath}/UserPlugins/ReaSonus"
    locale_file="$locale_dir/en-US.ini"
    src="${reasonus}/UserPlugins/ReaSonus/en-US.ini"

    mkdir -p "$locale_dir"

    # Replace a previous symlink (from an earlier activation) with a real file.
    if [ -L "$locale_file" ]; then
      rm -f "$locale_file"
    fi

    if [ ! -e "$locale_file" ] || ! cmp -s "$src" "$locale_file"; then
      $VERBOSE_ECHO "reasonusLocales: installing $locale_file"
      install -m 0644 "$src" "$locale_file"
    fi
  '';
}
