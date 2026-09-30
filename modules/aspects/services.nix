{
  flake.modules.nixos.services = { pkgs, ... }: {
    # --- MySQL (MariaDB) ---
    # Пользователь root без пароля доступен только через sudo
    # (unix socket auth); для DBeaver: sudo mysql → создать пользователя.
    services.mysql = {
      enable = true;
      package = pkgs.mariadb;
    };

    # --- Docker ---
    virtualisation.docker.enable = true;

    # --- Прокси-клиент Throne настраивается в aspects/vpn.nix ---

    # Батарея: Serpantinum читает состояние через D-Bus сервис upower
    services.upower.enable = true;
  };
}
