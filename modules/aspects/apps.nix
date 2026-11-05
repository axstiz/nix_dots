{
  flake.modules.nixos.apps = { pkgs, ... }: {
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
