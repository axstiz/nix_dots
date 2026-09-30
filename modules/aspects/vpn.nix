{
  flake.modules.nixos.vpn = { inputs, pkgs, ... }: {
    nixpkgs.overlays = [
      (_: _: { throne = inputs.nixpkgs-stable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.throne; })
    ];

    # Модуль из nixos-unstable конфликтует с импортированным из nixpkgs-stable
    # по одноимённым опциям, поэтому отключаем первый.
    disabledModules = [ "programs/throne.nix" ];
    imports = [ "${inputs.nixpkgs-stable}/nixos/modules/programs/throne.nix" ];

    programs.throne = {
      enable = true;
      tunMode = {
        enable = true;
        setuid = true;
      };
    };

    # Throne 1.2.2 из nixos-unstable тянет sing-box 1.13.x, где переписан
    # auto_redirect и объявлен deprecated strict_route. На NixOS связка
    # ломает TUN, поэтому пакет берём из nixpkgs-stable.
    boot.kernel.sysctl = {
      # sing-tun исключает собственный трафик по fwmark 0x2023/0x2024;
      # ядро учитывает mark при обратной проверке источника только с
      # src_valid_mark=1, иначе маркированный асимметричный трафик
      # (вход из туннеля, выход в wlo1) отбрасывается на rp_filter.
      "net.ipv4.conf.all.src_valid_mark" = 1;
      "net.ipv4.conf.default.src_valid_mark" = 1;
    };
  };
}
