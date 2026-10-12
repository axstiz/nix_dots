{
  flake-file.inputs.pixie-sddm = {
    url = "github:xCaptaiN09/pixie-sddm";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake-file.inputs.noctalia-sddm = {
    url = "github:mahaveergurjar/sddm?ref=noctalia";
    flake = false;
  };

  flake-file.inputs.nothing-sddm = {
    url = "github:mahaveergurjar/sddm?ref=nothing";
    flake = false;
  };

  flake.modules.nixos.wm =
    { inputs, pkgs, ... }:
    let
      # Greeter-тема Nothing (Nothing OS): минималистичный QML-набор.
      # Ветка без metadata.desktop/theme.conf — генерируем их сами и
      # подменяем заглушку-аватар user.jpg на свой.
      nothingTheme = pkgs.stdenvNoCC.mkDerivation {
        pname = "sddm-nothing";
        version = "1.0";
        src = inputs.nothing-sddm;
        dontConfigure = true;
        dontBuild = true;
        installPhase = ''
          runHook preInstall
          dir=$out/share/sddm/themes/nothing
          mkdir -p "$dir"
          cp -r $src/. "$dir/"
          chmod -R u+w "$dir"
          rm -f "$dir/README.md" "$dir/image.png"
          cp ${./_assets/greeter-avatar.jpg} "$dir/user.jpg"

          # Акцент и цвет текста берём из theme.conf (фолбэк — исходные значения).
          sed -i 's,"#aa3333",(config.accent || "#aa3333"),g' "$dir/Main.qml"
          sed -i 's,"white",(config.text || "white"),g' "$dir/Main.qml"

          printf '%s\n' \
            '[General]' \
            '# Акцент: границы, кнопки, глиф сессии' \
            'accent=#907aa9' \
            '# Цвет текста' \
            'text=white' \
            > "$dir/theme.conf"
          printf '%s\n' \
            '[SddmGreeterTheme]' \
            'Name=Nothing' \
            'Description=Nothing OS SDDM Theme' \
            'Author=mahaveergurjar' \
            'License=MIT' \
            'Type=greeter' \
            'Version=1.0' \
            'MainScript=Main.qml' \
            'ConfigFile=theme.conf' \
            'Theme-Id=nothing' \
            'Theme-API=2.0' \
            'QtVersion=6' \
            > "$dir/metadata.desktop"
          runHook postInstall
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
        # Активная тема: Nothing — на данный момент самая красивая из найденных
        # (монохром + акцент Rosé Pine Iris #907aa9). Сниппеты для возврата к
        # Pixie/Noctalia — в SDDM_THEMES.md.
        theme = "${nothingTheme}/share/sddm/themes/nothing";
        # QML-зависимости темы в окружение гритера: обёртка sddm собирает
        # QML import-пути из extraPackages (qtwayland добавляет сам модуль).
        # Ничего/Nothing использует qt5compat (GraphicalEffects).
        extraPackages =
          with pkgs.qt6;
          [
            qtdeclarative
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
