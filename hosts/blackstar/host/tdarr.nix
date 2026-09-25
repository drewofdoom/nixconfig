{
  pkgs,
  inputs,
  ...
}:

{
  # -- Tdarr node (Blackstar only, mapped) --
  # Server lives on rosie (compose: internal node `rosie`, serverPort 8266,
  # auth disabled, so no API key needed). This node gets 1 NVENC GPU worker;
  # server disk speed is the bottleneck, so no more.
  # Mapped = node reads/writes the library directly via /mnt/data/media below,
  # which mirrors the server's paths, so no pathTranslators needed.
  # Node polls the server outbound -- no inbound firewall ports needed.
  services.tdarr.nodes.blackstar = {
    name = "blackstar";
    # Stable's tdarr-node (2.74.01) can't build: its ccextractor dep
    # (0.94-unstable-2025-05-20) fails with "stray '#'" errors under gcc 15.
    # Unstable's node (2.86.01, ccextractor 0.96.6) has the fix. Imported
    # with allowUnfree since the raw flake input doesn't inherit
    # nixpkgs.config.allowUnfree (tdarr-node is unfree).
    package =
      (import inputs.nixpkgs-unstable {
        system = pkgs.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      }).tdarr-node;
    serverURL = "http://tdarr.bunny-octatonic.ts.net:8266";
    type = "mapped";
    startPaused = false;
    workers.transcodeGPU = 1;
    workers.transcodeCPU = 0;
    workers.healthcheckGPU = 0;
    workers.healthcheckCPU = 0;
  };

  # Pin tdarr to uid/gid 911 to match the server container's PUID/PGID=911,
  # so files created through the CIFS mount share ownership with the server.
  users.users.tdarr.uid = 911;
  users.groups.tdarr.gid = 911;

  # Tdarr_Node 2.86 uses serverURL only for the initial engine check; all
  # ongoing API calls go to serverIP:serverPort (default 0.0.0.0:8266 --
  # the ECONNREFUSED in the logs). The module sets no serverIP, so override
  # it here. Hostname, not the raw tailnet IP: :8266 is only reachable
  # through the Tailscale Serve frontend (tdarr.bunny-octatonic.ts.net),
  # direct-to-IP on 8266 is refused.
  systemd.services.tdarr-node-blackstar.environment = {
    serverIP = "tdarr.bunny-octatonic.ts.net";
    serverPort = "8266";
  };

  # The node stages transcodes under /temp (mirrors the compose `tdarr_cache:/temp`
  # volume). The unit's strict sandbox can't write there by default, so create
  # it and whitelist it.
  systemd.tmpfiles.rules = [
    "d /temp 0750 tdarr tdarr -"
    # Audio subvolumes are root-owned; hand them to drew (audio work runs as
    # the desktop user). tmpfiles runs at boot and adopts the mountpoints each
    # time, so ownership survives even if a subvol is recreated.
    "d /home/drew/Audio 0755 drew users -"
    "d /home/drew/Audio/Archive 0755 drew users -"
    "d /home/drew/Audio/Assets 0755 drew users -"
    "d /home/drew/Audio/Workspace 0755 drew users -"
  ];
  systemd.services.tdarr-node-blackstar.serviceConfig.ReadWritePaths = [ "/temp" ];

  # -- CIFS mount for the server's media share --
  # Credentials live OUTSIDE the repo at /etc/samba/media.credentials (root,
  # mode 0600) -- create it with:
  #   sudo mkdir -p /etc/samba
  #   printf 'username=\npassword=\n' | sudo tee /etc/samba/media.credentials
  #   sudo chmod 0600 /etc/samba/media.credentials
  # then fill in the values. The SMB user needs read+write on the share --
  # a mapped node writes transcoded files back to the library.
  # automount = the share is only connected on first access, and
  # idle-timeout disconnects it after 60s idle. nofail so a missing
  # file/share never blocks boot.
  environment.systemPackages = [ pkgs.cifs-utils ];
  fileSystems."/mnt/data/media" = {
    device = "//192.168.0.27/media";
    fsType = "cifs";
    options = [
      "credentials=/etc/samba/media.credentials"
      "uid=911,gid=911"
      "x-systemd.automount"
      "x-systemd.idle-timeout=60"
      "nofail"
      "rw"
    ];
  };
}
