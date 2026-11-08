{
  flake.modules.nixos.vpn = { inputs, pkgs, ... }: {
    nixpkgs.overlays = [
      (_: _: { throne = inputs.nixpkgs-stable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.throne; })
      (_: prev: { sotavpn = prev.callPackage ./_sotavpn.nix { }; })
    ];

    disabledModules = [ "programs/throne.nix" ];
    imports = [ "${inputs.nixpkgs-stable}/nixos/modules/programs/throne.nix" ];

    programs.throne = {
      enable = true;
      package = pkgs.throne;
      tunMode = {
        enable = true;
        setuid = true;
      };
    };

    local.unfreePackages = [ "sotavpn" ];

    environment.systemPackages = [ pkgs.sotavpn ];

    # kittend держит контрольный сокет /run/sota-connect/kittend.sock в группе
    # sota-connect; GUI подключается к демону только при членстве в ней.
    users.groups."sota-connect" = { };
    users.users.litsummer.extraGroups = [ "sota-connect" ];

    # Юнит повторяет шаблон из deb (usr/lib/systemd/system/sota-connect.service).
    # AF_NETLINK + CAP_SYS_PTRACE + CAP_DAC_READ_SEARCH там не декоративны:
    # через них sing-box ищет процессы для per-app split-tunnel.
    systemd.services.sota-connect = {
      description = "Sota Connect VPN daemon (KittenCore)";
      documentation = [ "https://sotavpn.net/" ];
      after = [ "network.target" ];
      wants = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.sotavpn}/libexec/sota-connect/kittend --state-dir /var/lib/sota-connect --endpoint /run/sota-connect/kittend.sock --socket-group sota-connect";
        Group = "sota-connect";
        RuntimeDirectory = "sota-connect";
        RuntimeDirectoryMode = "0750";
        StateDirectory = "sota-connect";
        StateDirectoryMode = "0710";
        Restart = "on-failure";
        RestartSec = "5";
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        ReadWritePaths = [ "/var/lib/sota-connect" ];
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
        ];
        AmbientCapabilities = [
          "CAP_NET_ADMIN"
          "CAP_NET_RAW"
          "CAP_NET_BIND_SERVICE"
          "CAP_CHOWN"
          "CAP_FOWNER"
          "CAP_SYS_PTRACE"
          "CAP_DAC_READ_SEARCH"
        ];
        CapabilityBoundingSet = [
          "CAP_NET_ADMIN"
          "CAP_NET_RAW"
          "CAP_NET_BIND_SERVICE"
          "CAP_CHOWN"
          "CAP_FOWNER"
          "CAP_SYS_PTRACE"
          "CAP_DAC_READ_SEARCH"
        ];
        SystemCallFilter = [
          "~open_by_handle_at"
          "~name_to_handle_at"
        ];
        StandardOutput = "journal";
        StandardError = "journal";
        SyslogIdentifier = "kittend";
      };
    };
  };
}
