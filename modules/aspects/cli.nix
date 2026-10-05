{
  flake.modules.nixos.cli = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      # Инструменты разработки
      git
      gh
      lazygit

      # Просмотр и навигация
      bat
      bk
      epy
      eza
      fzf
      glow
      termpdfpy
      zoxide
      duf
      tree
      yazi

      # Мониторинг системы
      btop
      ncdu
      nms

      # Архиваторы
      zip
      unzip
      p7zip
      unrar

      # Базовые утилиты
      vim
      wget
      xdg-user-dirs

      # Данные и сводка
      jq
      fastfetch

      # Справка и перевод
      cheat
      tldr
      translate-shell
    ];
  };

  flake.modules.homeManager.cli = { ... }: {
    # termpdf.py ищет браузер по списку gnome-open → gvfs-open → xdg-open → kde-open → firefox.
    # У нас находится xdg-open, а он на NixOS без mimeapps.list открывает ссылки молча.
    home.file.".config/termpdf.py/config".text = ''{ "URL_BROWSER": "firefox" }'';
  };
}
