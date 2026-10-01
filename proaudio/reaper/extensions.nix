# REAPER extensions: ReaPack (package repos) and SWS.
#
# ReaPack itself is provided by reaper-flake (a patched build); this file only
# configures it. The repository list lives in ./reapack-repos.nix.
{
  ...
}:

{
  programs.reaper.extensions = {
    reapack = {
      enable = true;
      repositories = import ./reapack-repos.nix;
      installNewPackagesWhenSynchronizing = false;
      enablePrereleasesGlobally = false;
      promptToUninstallObsoletePackages = true;
      synchronizeOnActivation = true;
      addDefaultRepositories = true;
      browser = {
        expandSynonyms = true;
      };
      network = {
        verifyPeer = true;
        proxy = "";
        refreshIndexCacheAfterSeconds = 604800;
      };
    };

    sws = {
      enable = true;
      colors = [
        "#eb6f92"
        "#f6c177"
        "#ebbcba"
        "#31748f"
        "#9ccfd8"
        "#c4a7e7"
        "#6e6a86"
        "#908caa"
        "#e0def4"
        "#21202e"
        "#403d52"
        "#524f67"
      ];
    };
  };
}
