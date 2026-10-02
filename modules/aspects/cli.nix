{
  flake.modules.nixos.cli = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      # Инструменты разработки
      git
      gh
      lazygit

      # Просмотр и навигация
      bat
      eza
      fzf
      glow
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
}
