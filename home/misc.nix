# Misc home settings: pager, PATH, folder icon activation.
# Moved verbatim from home-common.nix.
{
  pkgs,
  lib,
  config,
  ...
}:

{
  home = {
    sessionVariables = {
      PAGER = "bat";
      GLOW_STYLE = "${config.xdg.configHome}/glow/noctalia.json";
    };

    sessionPath = [ "$HOME/.local/bin" ];
  };
}
