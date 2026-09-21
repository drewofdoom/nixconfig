# SSH agent via proton-pass-cli. Moved verbatim from home-common.nix.
# Uses proton-pass as a drop-in ssh-agent, storing keys in Proton Pass.
# Secret backend uses dbus (gnome-keyring), enabled in system/hardware.nix.
{ pkgs, ... }:

{
  home.sessionVariables = {
    SSH_AUTH_SOCK = "$HOME/.ssh/proton-pass-agent.sock";
    PROTON_PASS_LINUX_KEYRING = "dbus";
  };

  systemd.user.services.proton-pass-ssh-agent = {
    Unit = {
      Description = "Proton Pass SSH Agent";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.proton-pass-cli}/bin/pass-cli ssh-agent start --socket-path %h/.ssh/proton-pass-agent.sock";
      Environment = "PROTON_PASS_LINUX_KEYRING=dbus";
      Restart = "on-failure";
      RestartSec = 1;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
