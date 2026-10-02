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
    pathTranslators = [
      {
        server = "/mnt/data/tmp_tdarr";
        node = "/var/cache/tdarr";
      }
    ];
  };

  # Pin tdarr to uid/gid 911 to match the server container's PUID/PGID=911,
  # so files created through the CIFS mount share ownership with the server.
  users = {
    users.tdarr.uid = 911;
    groups.tdarr.gid = 911;
  };

  systemd = {
    services = {
      tdarr-node-blackstar = {
        environment = {
          serverIP = "tdarr.bunny-octatonic.ts.net";
          serverPort = "8266";
        };

        # Transcode cache dir
        serviceConfig.ReadWritePaths = [
          "/var/cache/tdarr"
          "/temp"
        ];
      };
    };

    # Transcode cache dir
    tmpfiles.rules = [
      "d /var/cache/tdarr 0750 tdarr tdarr -"
      "d /temp 0750 tdarr tdarr -"
    ];
  };

  # -- CIFS mount for the server's media share --
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
