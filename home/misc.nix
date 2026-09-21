# Misc home settings: pager, PATH, folder icon activation.
# Moved verbatim from home-common.nix.
{
  pkgs,
  lib,
  ...
}:

{
  home.sessionVariables = {
    PAGER = "bat";
  };

  # Upstream opencode binary (see shell.nix note).
  home.sessionPath = [
    "$HOME/.opencode/bin"
    "$HOME/.local/bin"
  ];

  # Papirus "projects" folder icon on ~/Projects (GIO metadata lives in the
  # binary gvfs-metadata store, so this re-applies it idempotently each switch
  # instead of a config file). Guarded: a missing session bus never fails activation.
  home.activation.projectsFolderIcon = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    GIO="${pkgs.glib.bin}/bin/gio"
    dir="$HOME/Projects"
    if [ -d "$dir" ]; then
      curIcon=$("$GIO" info -a metadata::custom-icon-name "$dir" 2>/dev/null | sed -n 's/^  metadata::custom-icon-name: //p')
      if [ "$curIcon" != "folder-projects" ]; then
        "$GIO" set -t string "$dir" metadata::custom-icon-name folder-projects 2>/dev/null || true
      fi
    fi
  '';
}
