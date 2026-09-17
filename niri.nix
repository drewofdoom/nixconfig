# Niri config split into flat KDL files under niri/*.kdl.
# config.kdl includes noctalia.kdl (written by Noctalia's "niri" template),
# plus hardware/layout/binds/rules distributed below.
{ ... }:

{
  xdg.configFile = {
    "niri/config.kdl".source = ./niri/config.kdl;
    "niri/binds.kdl".source = ./niri/binds.kdl;
    "niri/layout.kdl".source = ./niri/layout.kdl;
    "niri/rules.kdl".source = ./niri/rules.kdl;
    "niri/inputs.kdl".source = ./niri/inputs.kdl;
  };
}
