# Niri config split into flat KDL files under niri/*.kdl.
# config.kdl includes noctalia.kdl (written by Noctalia's "niri" template),
# plus hardware/layout/binds/rules distributed below.
{ pkgs, ... }:

{
  programs.niri.enable = true;

  xdg.configFile = {
    "niri/config.kdl".source =
      pkgs.runCommand "niri-config-checked"
        {
          nativeBuildInputs = [ pkgs.niri ];
        }
        ''
          niri validate --config ${./config.kdl}
          cp ${./config.kdl} $out
        '';
    "niri/binds.kdl".source = ./niri/binds.kdl;
    "niri/layout.kdl".source = ./niri/layout.kdl;
    "niri/rules.kdl".source = ./niri/rules.kdl;
    "niri/inputs.kdl".source = ./niri/inputs.kdl;
  };
}
