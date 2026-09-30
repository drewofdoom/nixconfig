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
    };
  };
}
