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
          # Проверка доступности (captive portal): NM сам отличает сеть с
          # регистрацией (connectivity = portal) от обычной. Дефолтный NM-URI
          # (gstatic generate_204) порт белый-листит → NM видит full и портал
          # не детектится. Ставим GNOME-эндпоинт, который порты не белый-листят:
          # на редиректе на страницу входа NM вернёт portal. Интервал укорочен
          # с дефолтных 300 с. Состояние читает ~/bin/captive-portal-watch.sh
          # (см. homeManager-модуль ниже).
          settings.connectivity = {
            enabled = true;
            uri = "http://nmcheck.gnome.org/check_network_status.txt";
            response = "NetworkManager is online";
            interval = 60;
          };
        };
      };
    };

  flake.modules.homeManager.networking = { ... }: {
    # Открывает страницу входа при подключении к сети с регистрацией
    # (captive portal). Запускается через exec-once в wm/home.nix.
    home.file."bin/captive-portal-watch.sh" = {
      source = ./networking/captive-portal-watch.sh;
      executable = true;
    };
  };
}
