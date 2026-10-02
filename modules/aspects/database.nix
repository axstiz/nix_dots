{
  # GUI-клиент к БД. Сервер — mariadb в aspects/services.nix.
  flake.modules.nixos.database = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [ dbeaver-bin ];
  };
}
