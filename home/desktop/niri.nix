# Niri config split into flat KDL files under niri/*.kdl.
# config.kdl includes noctalia.kdl (written by Noctalia's "niri" template),
# plus layout/binds/rules distributed below. hardware.kdl (monitor layouts) is
# intentionally NOT managed here -- it is hand-written per machine.
{ ... }:

{
  xdg.configFile = {
    "niri/config.kdl".source = ./niri/config.kdl;
    "niri/binds.kdl".source = ./niri/binds.kdl;
    "niri/layout.kdl".source = ./niri/layout.kdl;
    "niri/rules.kdl".source = ./niri/rules.kdl;
  };
}
