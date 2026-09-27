{
  flake.modules.homeManager.zed = { pkgs, ... }: {
    # zed-editor кладёт .desktop и иконки в store, но environment.systemPackages
    # их не регистрирует — линкуем в пользовательские XDG-каталоги, чтобы Zed
    # появился в лаунчере. Сам пакет ставится в аспекте nixos.dev.
    home.file = {
      ".local/share/applications/dev.zed.Zed.desktop".source =
        "${pkgs.zed-editor}/share/applications/dev.zed.Zed.desktop";
      ".local/share/icons/hicolor/512x512/apps/zed.png".source =
        "${pkgs.zed-editor}/share/icons/hicolor/512x512/apps/zed.png";
      ".local/share/icons/hicolor/512x512@2/apps/zed.png".source =
        "${pkgs.zed-editor}/share/icons/hicolor/512x512@2/apps/zed.png";
    };

    # В nixpkgs CLI Zed называется zeditor; симлинк даёт привычное имя zed.
    home.file."bin/zed".source = "${pkgs.zed-editor}/bin/zeditor";
  };
}
