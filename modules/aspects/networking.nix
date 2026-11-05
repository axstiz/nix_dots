{
  flake.modules.nixos.networking =
    { pkgs, config, ... }:
    let
      h = config._module.args.host or { };
    in
    {
      networking = {
        hostName = h.name or "nixos";
        domain = h.domain or null;
        nftables.enable = true;
        firewall = {
          enable = true;
          allowPing = false;
          allowedTCPPorts = h.firewall.allowedTCPPorts or [ ];
          allowedUDPPorts = h.firewall.allowedUDPPorts or [ ];
        };
        networkmanager = {
          enable = true;
          package = pkgs.networkmanager;
          # Отключаем рандомизацию MAC (настройки самого профиля это не задевает):
          # NM рандомизирует MAC при каждом wifi-скане, и на части драйверов
          # после скана интерфейс остаётся со случайным адресом. Тогда
          # роутер (MikroTik) считает устройство «новым», DHCP-аренда и
          # captive-portal-сессия (привязана к MAC) рвутся — сервер портала
          # отдаёт NotFound при повторном входе. permanent = заводской MAC
          # устройства всегда, scanRandMacAddress=false — и сканы не подменяют его.
          wifi = {
            macAddress = "permanent";
            scanRandMacAddress = false;
          };
        };
      };
    };
}
