{
  flake.modules.nixos.apps = { pkgs, ... }: {
    # gvfs нужен nautilus для виртуальных URI: trash и т.п.
    # Без него nautilus не открывает корзину.
    services.gvfs.enable = true;

    environment.systemPackages = with pkgs; [
      telegram-desktop
      yandex-music
      obsidian
      nautilus
      zotero
      # GUI-менеджер сетей NetworkManager (открывается из мини-панели
      # wifi-виджета Serpantinum). networkmanagerapplet даёт бинарник
      # nm-connection-editor; иконка трея (nm-applet) не используется.
      networkmanagerapplet
    ];
  };
}
