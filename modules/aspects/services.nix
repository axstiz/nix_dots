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

    # --- Прокси-клиент Throne (Qt GUI + встроенный core, без ручной докачки) ---
    programs.throne = {
      enable = true;
      tunMode = {
        enable = true;
        setuid = true;
      };
    };

    # Батарея: Serpantinum читает состояние через D-Bus сервис upower
    services.upower.enable = true;
  };
}
