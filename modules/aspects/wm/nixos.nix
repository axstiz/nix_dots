{
  flake-file.inputs.sddm-wired-theme = {
    url = "git+https://github.com/faisalhsn/sddm-wired-theme?shallow=1";
    flake = false;
  };

  flake.modules.nixos.wm =
    { inputs, pkgs, ... }:
    let

      # Тема sddm-wired-theme (Serial Experiments Lain): гиф-фон, музыка и звук
      # логина с любого закоса. В nixpkgs её нет — собираем из flake-инпута.
      wiredTheme = pkgs.stdenvNoCC.mkDerivation {
        pname = "sddm-wired-theme";
        version = "2024-06-21";
        src = inputs.sddm-wired-theme;
        dontConfigure = true;
        dontBuild = true;
        installPhase = ''
          mkdir -p $out/share/sddm/themes/sddm-wired-theme
          cp -r $src/* $out/share/sddm/themes/sddm-wired-theme/
        '';
      };
    in
    {
      environment.sessionVariables = {
        NIXOS_OZONE_WL = "1";
        MOZ_ENABLE_WAYLAND = "1";
      };

      # --- ДИСПЛЕЙНЫЙ МЕНЕДЖЕР (greeter) ---
      # SDDM: Qt6/QML-гритер, нативный Wayland (без xserver-стека).
      services.displayManager.sddm = {
        enable = true;
        wayland.enable = true;
        theme = "${wiredTheme}/share/sddm/themes/sddm-wired-theme";
        # QML-зависимости темы в окружение гритера: обёртка sddm собирает
        # QML import-пути из extraPackages (qtwayland добавляет сам модуль).
        # Wired-теме нужен qtmultimedia (музыка/звук логина) под Qt6.
        extraPackages =
          with pkgs.qt6;
          [
            qtsvg
            qt5compat
          ]
          ++ [ pkgs.qt6Packages.qtmultimedia ];
      };

      programs.hyprland = {
        enable = true;
        withUWSM = true;
      };

      # --- ПАКЕТЫ WM: бинды, скриншоты, клипборд, тема курсора ---
      environment.systemPackages = with pkgs; [
        pywal
        dart-sass
        rose-pine-hyprcursor
        wl-clipboard
        cliphist
        # Инструменты для биндов и скриншотов
        grim
        slurp
        swappy
        fuzzel
        playerctl
        hyprpicker
      ];
    };
}
