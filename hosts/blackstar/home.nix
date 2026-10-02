# blackstar-only home config.
#
# The `backend` block exposes this instance's Hermes on the tailnet so a
# Hermes Desktop on another machine can attach to it as a remote gateway.
#
# `serve` gives the /api/ws and /api/pty sockets without a browser UI, which
# is what a remote Desktop needs. It shares one HERMES_HOME with the messaging
# gateway, so sessions, memory, skills and cron are the same on both sides
# rather than duplicated per machine.
#
# Bound to the MagicDNS FQDN, NOT 0.0.0.0. The server rejects any request whose
# Host header differs from the bind address (DNS-rebinding defense,
# GHSA-ppp5-vxwm-4cf7), and a wildcard bind disables that check entirely.
# Clients must use this exact hostname, which is also declared as
# dashboard.public_url below so Host and WS Origin validation agree.
#
# waitFor = "hostname" polls until MagicDNS resolves: tailscaled is a system
# unit and a systemd *user* unit cannot order itself after it, so a dependency
# there would be a silent no-op.
#
# A non-loopback bind REQUIRES an auth provider -- without one the backend fails
# closed at startup, and --insecure is a deprecated no-op since the June 2026
# hardening. Credentials come per-machine from ~/.config/hermes/env (wired via
# environmentFiles in home/hermes.nix):
#   HERMES_DASHBOARD_BASIC_AUTH_USERNAME
#   HERMES_DASHBOARD_BASIC_AUTH_PASSWORD
#   HERMES_DASHBOARD_BASIC_AUTH_SECRET   (restart-stable sessions)
# Deliberately not in this repo: a Nix expression is world-readable in /nix/store.

{ ... }:

{
  imports = [
    ./backup.nix
    ./home/packages.nix
    ./home/gaming.nix
    ./home/hermes.nix
  ];
}
