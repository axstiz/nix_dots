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

  flake-file.inputs.pixel-sddm = {
    url = "github:mahaveergurjar/sddm?ref=pixel";
    flake = false;
  };

  flake-file.inputs.ronin-sddm = {
    url = "github:mahaveergurjar/sddm?ref=ronin";
    flake = false;
  };

  flake.modules.nixos.wm =
    { inputs, pkgs, ... }:
    let
      # Палитра активной системы (serpantinum → CustomTheme / Catppuccin Mocha
      # с чёрным base; matugen выключен).
      systemPalette = {
        base = "#000000";
        mantle = "#0b0b0d";
        surface0 = "#1d1d22";
        surface1 = "#2b2b33";
        surface2 = "#393944";
        text = "#eeeff2";
        subtext0 = "#b8bbc2";
        accent = "#cba6f7";
        pink = "#f5c2e7";
        red = "#f38ba8";
        teal = "#94e2d5";
      };

      # Протестированные greeter-темы. Активная выбирается ниже строкой
      # activeSddmTheme; каталог темы в сторе совпадает с именем ключа.
      themes = {
        # Pixie (Pixel / Material 3), акцент автоцветом из обоев.
        pixie = inputs.pixie-sddm.packages.${pkgs.system}.pixie-sddm.override {
          background = ./_assets/greeter-bg.png;
          avatar = ./_assets/greeter-avatar.jpg;
          autoColor = true;
          backgroundColor = "#1A1C1E";
          textColor = "#E3E3DC";
          use24HourClock = true;
        };

        # Noctalia (Rosé Pine): плоский QML-набор.
        noctalia = pkgs.stdenvNoCC.mkDerivation {
          pname = "sddm-noctalia";
          version = "1.0";
          src = inputs.noctalia-sddm;
          dontConfigure = true;
          dontBuild = true;
          installPhase = ''
            mkdir -p $out/share/sddm/themes/noctalia
            cp -r $src/. $out/share/sddm/themes/noctalia/
          '';
        };

        # Nothing (Nothing OS): ветка без metadata/theme.conf — генерируем их и
        # подменяем заглушку-аватар на свой.
        nothing = pkgs.stdenvNoCC.mkDerivation {
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

        # Pixel (Android 16 / Pixel UI, «ii-lock»): KDE-метаданные неполные —
        # дописываем корректный metadata.desktop, перекрашиваем зашитые
        # amber-цвета в палитру системы и ставим активные обои фоном.
        pixel = pkgs.stdenvNoCC.mkDerivation {
          pname = "sddm-pixel";
          version = "1.0";
          src = inputs.pixel-sddm;
          nativeBuildInputs = [ pkgs.imagemagick ];
          dontConfigure = true;
          dontBuild = true;
          installPhase = ''
            runHook preInstall
            dir=$out/share/sddm/themes/pixel
            mkdir -p "$dir"
            cp -r $src/. "$dir/"
            chmod -R u+w "$dir"
            rm -f "$dir/README.md" "$dir/image.png" "$dir/image2.png"

            magick ${./_assets/greeter-wallpaper.jpg} "$dir/assets/background.png"

            # amber → палитра системы (регистронезависимо).
            for f in "$dir/Main.qml" "$dir/AnalogBadge.qml" \
              "$dir/VirtualKeyboard.qml" "$dir/PixelDots.qml"; do
              sed -i \
                -e 's/#f4c16e/${systemPalette.accent}/gI' \
                -e 's/#c1883e/${systemPalette.accent}/gI' \
                -e 's/#2c1b0d/${systemPalette.mantle}/gI' \
                -e 's/#1e120a/${systemPalette.mantle}/gI' \
                -e 's/#3a2616/${systemPalette.surface1}/gI' \
                -e 's/#3b2513/${systemPalette.surface1}/gI' \
                -e 's/#452f1e/${systemPalette.surface1}/gI' \
                -e 's/#653e00/${systemPalette.surface1}/gI' \
                -e 's/#4e3725/${systemPalette.surface0}/gI' \
                -e 's/#8f6b3c/${systemPalette.surface2}/gI' \
                -e 's/#f2e7d5/${systemPalette.text}/gI' \
                -e 's/#d6c3a1/${systemPalette.subtext0}/gI' \
                -e 's/#c4ab8f/${systemPalette.subtext0}/gI' \
                -e 's/#cccccc/${systemPalette.subtext0}/gI' \
                -e 's/#a8cf9c/${systemPalette.teal}/gI' \
                "$f"
            done

            printf '%s\n' \
              '[SddmGreeterTheme]' \
              'Name=Pixel' \
              'Description=Pixel UI SDDM Theme' \
              'Author=mahaveergurjar' \
              'License=MIT' \
              'Type=greeter' \
              'Version=1.0' \
              'MainScript=Main.qml' \
              'ConfigFile=theme.conf' \
              'Theme-Id=pixel' \
              'Theme-API=2.0' \
              'QtVersion=6' \
              > "$dir/metadata.desktop"
            runHook postInstall
          '';
        };

        # Ronin (Demon Slayer, hyprlock-style): Qt5-импорт GraphicalEffects и
        # чужие абсолютные пути — чиним; перекрашиваем и ставим свои обои/аватар.
        ronin = pkgs.stdenvNoCC.mkDerivation {
          pname = "sddm-ronin";
          version = "0.1";
          src = inputs.ronin-sddm;
          nativeBuildInputs = [ pkgs.imagemagick ];
          dontConfigure = true;
          dontBuild = true;
          installPhase = ''
            runHook preInstall
            dir=$out/share/sddm/themes/ronin
            mkdir -p "$dir/assets"
            cp -r $src/. "$dir/"
            chmod -R u+w "$dir"
            rm -f "$dir/README.md" "$dir/image.png"

            magick ${./_assets/greeter-wallpaper.jpg} "$dir/assets/background.png"
            cp ${./_assets/greeter-avatar.jpg} "$dir/avatar.jpg"

            # Qt6: старый URI GraphicalEffects переехал в Qt5Compat.
            sed -i 's/QtGraphicalEffects 1.15/Qt5Compat.GraphicalEffects 1.0/g' \
              "$dir/Main.qml" "$dir/BlurredCard.qml"

            # SddmComponents перебивает ComboBox из QtQuick.Controls — берём
            # его явно через алиас, а лишний импорт SddmComponents убираем.
            sed -i '/^import SddmComponents 2.0$/d' "$dir/Main.qml"
            sed -i \
              -e 's/^import QtQuick.Controls 2.15$/import QtQuick.Controls 2.15\nimport QtQuick.Controls 2.15 as QQC2/' \
              -e 's/ComboBox {/QQC2.ComboBox {/g' \
              "$dir/Main.qml"

            # Абсолютные пути/личные данные автора → свои.
            sed -i 's,file:///home/mahaveer/.config/hyprlock/wallpapers/me.jpeg,avatar.jpg,g' \
              "$dir/Main.qml"
            sed -i 's/Arch Linux/NixOS/g; s/, mahaveer//g' "$dir/Main.qml"

            # Demon Slayer → палитра системы (регистронезависимо).
            sed -i \
              -e 's/#BA3D3D/${systemPalette.accent}/gI' \
              -e 's/#191414/${systemPalette.base}/gI' \
              -e 's/#F0E6DC/${systemPalette.text}/gI' \
              -e 's/#B9AFA5/${systemPalette.subtext0}/gI' \
              -e 's/#CCA47C/${systemPalette.pink}/gI' \
              -e 's/#FF0000/${systemPalette.red}/gI' \
              "$dir/Main.qml"

            printf '%s\n' \
              '[General]' \
              'background=assets/background.png' \
              'type=image' \
              'color=#1f1f1f' \
              > "$dir/theme.conf"
            printf '%s\n' \
              '[SddmGreeterTheme]' \
              'Name=Ronin' \
              'Description=Ronin — Demon Slayer SDDM Theme' \
              'Author=Antigravity' \
              'License=GPL-3.0' \
              'Type=greeter' \
              'Version=0.1' \
              'MainScript=Main.qml' \
              'ConfigFile=theme.conf' \
              'Theme-Id=ronin' \
              'Theme-API=2.0' \
              'QtVersion=6' \
              > "$dir/metadata.desktop"
            runHook postInstall
          '';
        };

        # Catppuccin (официальный, из nixpkgs): Mocha + mauve под палитру
        # системы, свои обои. Каталог нормализуем до `catppuccin`.
        catppuccin = pkgs.runCommand "sddm-catppuccin" { } ''
          mkdir -p $out/share/sddm/themes/catppuccin
          cp -r ${
            pkgs.catppuccin-sddm.override {
              flavor = "mocha";
              accent = "mauve";
              font = "JetBrainsMono Nerd Font";
              fontSize = "10";
              background = ./_assets/greeter-wallpaper.jpg;
              loginBackground = true;
            }
          }/share/sddm/themes/catppuccin-mocha-mauve/. $out/share/sddm/themes/catppuccin/
        '';

        # Astronaut (Keyitdev, из nixpkgs): Qt6/QML-гритер, конфиг —
        # Themes/astronaut.conf. Каталог `sddm-astronaut-theme` нормализуем до
        # `astronaut`, подменяем фон и перекрашиваем конфиг под палитру системы.
        astronaut = pkgs.stdenvNoCC.mkDerivation {
          pname = "sddm-astronaut";
          version = "0-unstable";
          src = pkgs.sddm-astronaut;
          nativeBuildInputs = [ pkgs.imagemagick ];
          dontConfigure = true;
          dontBuild = true;
          installPhase = ''
            runHook preInstall
            dir=$out/share/sddm/themes/astronaut
            mkdir -p "$dir"
            cp -r $src/share/sddm/themes/sddm-astronaut-theme/. "$dir/"
            chmod -R u+w "$dir"

            magick ${./_assets/greeter-wallpaper.jpg} "$dir/Backgrounds/astronaut.png"

            conf="$dir/Themes/astronaut.conf"
            sed -i \
              -e 's|^Font=.*|Font="JetBrainsMono Nerd Font"|' \
              -e 's|^HeaderTextColor=.*|HeaderTextColor="${systemPalette.text}"|' \
              -e 's|^DateTextColor=.*|DateTextColor="${systemPalette.text}"|' \
              -e 's|^TimeTextColor=.*|TimeTextColor="${systemPalette.text}"|' \
              -e 's|^FormBackgroundColor=.*|FormBackgroundColor="${systemPalette.mantle}"|' \
              -e 's|^BackgroundColor=.*|BackgroundColor="${systemPalette.mantle}"|' \
              -e 's|^DimBackgroundColor=.*|DimBackgroundColor="${systemPalette.mantle}"|' \
              -e 's|^LoginFieldBackgroundColor=.*|LoginFieldBackgroundColor="${systemPalette.surface0}"|' \
              -e 's|^PasswordFieldBackgroundColor=.*|PasswordFieldBackgroundColor="${systemPalette.surface0}"|' \
              -e 's|^LoginFieldTextColor=.*|LoginFieldTextColor="${systemPalette.text}"|' \
              -e 's|^PasswordFieldTextColor=.*|PasswordFieldTextColor="${systemPalette.text}"|' \
              -e 's|^UserIconColor=.*|UserIconColor="${systemPalette.text}"|' \
              -e 's|^PasswordIconColor=.*|PasswordIconColor="${systemPalette.text}"|' \
              -e 's|^PlaceholderTextColor=.*|PlaceholderTextColor="${systemPalette.subtext0}"|' \
              -e 's|^WarningColor=.*|WarningColor="${systemPalette.red}"|' \
              -e 's|^LoginButtonTextColor=.*|LoginButtonTextColor="${systemPalette.base}"|' \
              -e 's|^LoginButtonBackgroundColor=.*|LoginButtonBackgroundColor="${systemPalette.accent}"|' \
              -e 's|^SystemButtonsIconsColor=.*|SystemButtonsIconsColor="${systemPalette.text}"|' \
              -e 's|^SessionButtonTextColor=.*|SessionButtonTextColor="${systemPalette.text}"|' \
              -e 's|^VirtualKeyboardButtonTextColor=.*|VirtualKeyboardButtonTextColor="${systemPalette.text}"|' \
              -e 's|^DropdownTextColor=.*|DropdownTextColor="${systemPalette.text}"|' \
              -e 's|^DropdownSelectedBackgroundColor=.*|DropdownSelectedBackgroundColor="${systemPalette.accent}"|' \
              -e 's|^DropdownBackgroundColor=.*|DropdownBackgroundColor="${systemPalette.surface0}"|' \
              -e 's|^HighlightTextColor=.*|HighlightTextColor="${systemPalette.subtext0}"|' \
              -e 's|^HighlightBackgroundColor=.*|HighlightBackgroundColor="${systemPalette.accent}"|' \
              -e 's|^HighlightBorderColor=.*|HighlightBorderColor="${systemPalette.accent}"|' \
              -e 's|^HoverUserIconColor=.*|HoverUserIconColor="${systemPalette.pink}"|' \
              -e 's|^HoverPasswordIconColor=.*|HoverPasswordIconColor="${systemPalette.pink}"|' \
              -e 's|^HoverSystemButtonsIconsColor=.*|HoverSystemButtonsIconsColor="${systemPalette.pink}"|' \
              -e 's|^HoverSessionButtonTextColor=.*|HoverSessionButtonTextColor="${systemPalette.pink}"|' \
              -e 's|^HoverVirtualKeyboardButtonTextColor=.*|HoverVirtualKeyboardButtonTextColor="${systemPalette.pink}"|' \
              -e 's|^FormPosition=.*|FormPosition="left"|' \
              -e 's|^BypassSystemButtonsChecks=.*|BypassSystemButtonsChecks="true"|' \
              "$conf"
            runHook postInstall
          '';
        };
      };

      # Курсор для weston-гритера. libwayland-cursor собирается с ICONDIR,
      # указывающим в несуществующий share-output (в nix `share` — отдельный
      # output), поэтому задаём XCURSOR_PATH на каталог с темой курсора.
      # weston грузит тему с именем `default`, потому кладём и её, и настоящее
      # имя (на случай, если тему запросят по имени из Theme.CursorTheme).
      sddmCursors = pkgs.runCommand "sddm-cursors" { } ''
        mkdir -p $out
        ln -s ${pkgs.rose-pine-cursor}/share/icons/BreezeX-RosePine-Linux $out/default
        ln -s ${pkgs.rose-pine-cursor}/share/icons/BreezeX-RosePine-Linux $out/BreezeX-RosePine-Linux
      '';

      # Активная тема. Лучшая — pixel.
      activeSddmTheme = "pixel";
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
        # Активная тема (ключ attrset = имя каталога темы в сторе).
        theme = "${themes.${activeSddmTheme}}/share/sddm/themes/${activeSddmTheme}";
        # QML-зависимости темы в окружение гритера: обёртка sddm собирает
        # QML import-пути из extraPackages (qtwayland добавляет сам модуль).
        extraPackages =
          with pkgs.qt6;
          [
            qtdeclarative
            qtsvg
            qt5compat
          ]
          ++ [
            pkgs.qt6Packages.qtmultimedia
            pkgs.qt6Packages.qtvirtualkeyboard
          ];
        settings.Theme = {
          CursorTheme = "BreezeX-RosePine-Linux";
          CursorSize = 24;
        };
      };

      # Путь к курсорам для sddm/weston (см. sddmCursors выше).
      services.displayManager.generic.environment.XCURSOR_PATH = "${sddmCursors}";

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
