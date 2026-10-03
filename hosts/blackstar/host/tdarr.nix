{
  pkgs,
  inputs,
  ...
}:

{
  # -- Tdarr node (Blackstar only, mapped) --
  # Server lives on rosie (compose: internal node `rosie`, serverPort 8266) and
  # now requires auth, so the node needs an API key. This node gets 1 NVENC GPU
  # worker; server disk speed is the bottleneck, so no more.
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

    # Server auth is enabled, so the node authenticates with an API key.
    # environmentFile keeps the key out of /nix/store (world-readable): the
    # module's own docs call this out as the intended path for `apiKey`. The
    # file is unmanaged, so provision it once per machine:
    #
    #   sudo install -d -m 0755 -o root -g root /etc/tdarr
    #   sudo sh -c 'umask 077; cat > /etc/tdarr/node.env' <<'EOF'
    #   apiKey=tapi_...
    #   EOF
    #
    # systemd reads EnvironmentFile as PID 1 before the service sandbox
    # (ProtectSystem=strict) applies, so root:root 0600 is fine and the key is
    # never readable by the tdarr user or anything else on the box.
    #
    # Caveat: a *missing* EnvironmentFile makes the unit fail to start rather
    # than degrade, so keep this in sync with any rebuild-from-scratch. This
    # file is deliberately NOT in the restic backup paths (backup.nix only
    # covers ~/Documents and friends); re-provision by hand like the hermes
    # env file and /etc/samba/media.credentials.
    environmentFile = "/etc/tdarr/node.env";
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
