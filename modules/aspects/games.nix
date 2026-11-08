{
  flake.modules.nixos.games =
    { pkgs, ... }:
    let
      # Sky Track (Sky Track 2040, 2009) — аркадные гонки: трассы-дороги парят
      # высоко в облаках, машины кастомизируются (прокачка + смена раскрасок).
      # Игра нативная для Windows (Direct3D9/D3DX9), поэтому запускаем через Wine.
      # Инсталлятор от GameTop собран в Inno Setup — распаковываем innoextract,
      # чтобы не тащить рекламную обёртку game-shell.exe.
      skyTrack = pkgs.stdenvNoCC.mkDerivation {
        pname = "sky-track";
        version = "2009";
        src = pkgs.fetchurl {
          url = "https://cdn7.gametop.com/games/Sky_Track.exe";
          hash = "sha256-EY2c57Un9P5+FT1WPqq1L3kmYwaYHLRGEqXPbQsW53E=";
        };
        nativeBuildInputs = with pkgs; [
          imagemagick
          innoextract
          icoutils
        ];
        dontUnpack = true;
        dontConfigure = true;
        dontBuild = true;
        installPhase = ''
          runHook preInstall
          mkdir -p $out/share/sky-track
          innoextract -e -I app -d $out/share/sky-track $src
          # Обёртка GameTop (лаунчер с рекламой) и её ресурсы не нужны.
          rm -f $out/share/sky-track/app/game-shell.exe
          rm -rf $out/share/sky-track/app/game-shell-data
          chmod +x $out/share/sky-track/app/game.exe

          # Иконка: в exe она только 48x48 (в installer'е — то же), вытаскиваем
          # group_icon через wrestool/icotool и отдаём в hicolor нативным
          # размером + апскейлом для дока.
          mkdir -p icons pngs
          wrestool -x -t 14 -n 101 -o icons "$out/share/sky-track/app/game.exe"
          icotool -x -o pngs icons/*.ico || true
          icon=$(echo pngs/*_48x48x24.png)
          for size in 48 256; do
            dir="$out/share/icons/hicolor/''${size}x''${size}/apps"
            mkdir -p "$dir"
            magick "$icon" -background none -filter Lanczos \
              -resize "''${size}x''${size}" "$dir/sky-track.png"
          done
          install -Dm644 "$out/share/icons/hicolor/256x256/apps/sky-track.png" \
            "$out/share/pixmaps/sky-track.png"

          install -Dm644 ${skyTrackDesktopItem}/share/applications/sky-track.desktop \
            "$out/share/applications/sky-track.desktop"
          runHook postInstall
        '';
      };

      skyTrackDesktopItem = pkgs.makeDesktopItem {
        name = "sky-track";
        desktopName = "Sky Track";
        comment = "Аркадные гонки на трассах в облаках (2009)";
        exec = "sky-track";
        icon = "sky-track";
        categories = [ "Game" ];
        terminal = false;
      };

      wine = pkgs.wineWow64Packages.stable;
    in
    {
      # 32-битная игра: Wine'у нужны 32-битные графические библиотеки.
      hardware.graphics.enable32Bit = true;

      environment.systemPackages = [
        wine
        pkgs.winetricks

        # Пакет игры: содержит .desktop и иконку, поэтому ссылается в
        # /run/current-system/sw/share/applications — оттуда его видит лаунчер.
        skyTrack

        (pkgs.writeShellApplication {
          name = "sky-track";
          runtimeInputs = [
            wine
            pkgs.coreutils
          ];
          text = ''
            # Игра пишет сохранения (Save/) и Game.ini рядом с собой, поэтому
            # копируем её из read-only store в домашний каталог при первом запуске.
            dataDir="''${XDG_DATA_HOME:-$HOME/.local/share}"
            gamedir="$dataDir/sky-track"
            if [ ! -e "$gamedir/game.exe" ]; then
              mkdir -p "$gamedir"
              cp -r ${skyTrack}/share/sky-track/app/. "$gamedir/"
              chmod -R u+w "$gamedir"
            fi
            export WINEPREFIX="''${WINEPREFIX:-$dataDir/wineprefixes/sky-track}"
            cd "$gamedir"
            exec wine ./game.exe "$@"
          '';
        })
      ];
    };
}
