{
  flake.modules.homeManager.serpantinum =
    {
      inputs,
      pkgs,
      lib,
      config,
      ...
    }:
    let
      # --- Прозрачности serpantinum: единый источник таблицы групп ---
      # Отсюда генерируются: (а) runtime-синглтон OpacityExt.qml, (б) таблица
      # для вкладки Guide «Расширенные настройки» (groups.json рядом с BetaTab).
      opacityGroups = import ./_assets/opacity-groups.nix;

      opacityExtQml = pkgs.writeText "OpacityExt.qml" ''
          pragma Singleton
          import QtQuick
          import Quickshell
          import Quickshell.Io

          // GENERATED from serpantinum/opacity-groups.nix — не править руками!
          // Рантайм-ручки прозрачности: значения читаются из settings.json
          // (theme.opacityExt, проценты 0..100) быстрым FileView-watcher'ом;
          // отсутствующий ключ = дефолт из этой таблицы (прежний вид).
          Item {
              id: root

              property var map: ({ })
              property int rev: 0

              FileView {
                  id: settingsWatcher
                  path: Quickshell.env("QS_SETTINGS") ? Quickshell.env("QS_SETTINGS")
                                                      : (Quickshell.env("HOME") + "/.config/serpantinum/settings.json")
                  watchChanges: true
                  onFileChanged: reload()

                  onLoaded: {
                      try {
                          let raw = typeof text === "function" ? text() : text;
                          let parsed = JSON.parse(String(raw));
                          let t = parsed.theme;
                          root.map = (t && t.opacityExt) ? t.opacityExt : { };
                          root.rev++;
                          console.log("[OpacityExt] refreshed rev=" + root.rev);
                      } catch (e) {
                          console.log("[OpacityExt] load failed: " + e);
                      }
                  }
              }

              Component.onCompleted: settingsWatcher.reload()

        ${lib.concatMapStrings (
          g: ''readonly property real ${g.key}: f("${g.key}", ${toString g.default})'' + "\n"
        ) opacityGroups}
              function f(key, defPct) {
                  let v = root.map[key];
                  return (typeof v === "number" && v >= 0) ? (v / 100.0) : (defPct / 100.0);
              }
          }
      '';

      opacityGroupsJson = pkgs.writeText "groups.json" (builtins.toJSON opacityGroups);

      # Каталог обоев: наша дефолтная картинка + коллекция автора шелла (shell-wallpapers).
      # ~/Pictures/Wallpapers — симлинк на этот store-путь; Serpantinum/matugen читают его
      # напрямую, отдельные файлы в профиль не копируются.
      wallpapers = pkgs.runCommand "serpantinum-wallpapers" { } ''
        mkdir -p "$out"
        cp ${./_assets/my_wallpaper.png} "$out/wallpaper.png"
        cp -a ${inputs.shell-wallpapers}/images/. "$out/"
      '';
    in
    {
      imports = [ inputs.serpantinum.homeManagerModules.default ];

      # --- Serpantinum shell (панель, лаунчер, шторки, lock-screen) ---
      programs.serpantinum = {
        enable = true;
        # Скрипт снимка экрана serpantinum модифицирован нашим вариантом (serpantinum/screenshot.sh):
        # после копирования в буфер файл удаляется — на диск ничего не сохраняется.
        package = inputs.serpantinum.packages.${pkgs.system}.default.overrideAttrs (old: {
          postInstall = (old.postInstall or "") + ''
            install -m0755 ${./_assets/screenshot.sh} "$out/share/serpantinum/scripts/screenshot.sh"
            # --- Прозрачности и вкладка «Расширенные настройки» ---
            # Патчи заменяют зашитые константы альфы на рантайм-ручки OpacityExt
            # (Config.rawSettings.theme.opacityExt.*, ключ — % непрозрачности 0..100).
            # Обнаруживать ключи в settings.json не нужно: отсутствие ключа = дефолт
            # из патча, который равен прежнему захардкоженному значению — после
            # переключения вид шелла 1-в-1 прежнему. Меняет значения вкладка
            # «Расширенные настройки» в Guide (файл beta/BetaTab.qml, ниже).
            cd "$out/share/serpantinum"
            patch -p1 < ${./_assets/theme-opacity.patch}
            patch -p1 < ${./_assets/sidebar-opacity.patch}
            patch -p1 < ${./_assets/sidebar-pills-opacity.patch}
            patch -p1 < ${./_assets/floating-opacity.patch}
            patch -p1 < ${./_assets/syspanel-opacity.patch}
            patch -p1 < ${./_assets/timer-opacity.patch}
            patch -p1 < ${./_assets/draw-opacity.patch}
            patch -p1 < ${./_assets/lock-opacity.patch}
            patch -p1 < ${./_assets/calendar-opacity.patch}
            patch -p1 < ${./_assets/extended-tab.patch}
            # Рантайм-синглтон прозрачности: СГЕНЕРИРОВАН из opacity-groups.nix
            install -m0644 ${opacityExtQml} "$out/share/serpantinum/quickshell/singletons/theme/OpacityExt.qml"
            sed -i "/singleton ThemeBackend 1.0/i singleton OpacityExt 1.0 singletons/theme/OpacityExt.qml" \
              "$out/share/serpantinum/quickshell/qmldir"
            # Вкладка «Расширенные настройки» (beta/BetaTab.qml) + таблица групп для неё
            mkdir -p "$out/share/serpantinum/quickshell/guide/beta"
            install -m0644 ${./_assets/beta/BetaTab.qml} \
              "$out/share/serpantinum/quickshell/guide/beta/BetaTab.qml"
            install -m0644 ${opacityGroupsJson} \
              "$out/share/serpantinum/quickshell/guide/beta/groups.json"
            # --- Виджет «Brain» (ASCII-мозг из that-ponderer/ZAPP) + 4 новых
            # терминал-стиль виджета (Matrix rain, CRT-часы, погода ASCII, Plasma):
            # регистрация в WidgetRegistry + i18n ключи (en/ru) через патч,
            # сами face-файлы кладём рядом с остальными faces.
            patch -p1 < ${./_assets/brain-widget.patch}
            install -m0644 ${./_assets/BrainFace.qml} \
              "$out/share/serpantinum/quickshell/widgets/faces/BrainFace.qml"
            install -m0644 ${./_assets/MatrixRainFace.qml} \
              "$out/share/serpantinum/quickshell/widgets/faces/MatrixRainFace.qml"
            install -m0644 ${./_assets/CrtClockFace.qml} \
              "$out/share/serpantinum/quickshell/widgets/faces/CrtClockFace.qml"
            install -m0644 ${./_assets/SkyFace.qml} \
              "$out/share/serpantinum/quickshell/widgets/faces/SkyFace.qml"
            install -m0644 ${./_assets/PlasmaFace.qml} \
              "$out/share/serpantinum/quickshell/widgets/faces/PlasmaFace.qml"
            # Точка приглушения warnings Qt Context2D (canvas): строка шрифта в
            # MatrixRainFace для скорости оставлена в bare-варианте, из-за чего
            # Context2D спамит "invalid font families" на каждый кадр. Гасим
            # только категорию qt.qml.context2d у процесса шелла — на прочие
            # Qt-приложения не влияет (это флаг quickshell --log-rules).
            sed -i 's|quickshell -p "$MAIN_QML" 9>&- |quickshell --log-rules "qt.qml.context2d.warning=false" -p "$MAIN_QML" 9>\&- |' \
              "$out/bin/.serpantinumd-wrapped"
            cd "$OLDPWD"
          '';
        });
        # Стартуем через exec-once в Hyprland — под SDDM graphical-session.target
        # неактивен, поэтому systemd-сервис не поднимется.
        systemd.enable = false;
        settings = {
          wallpaperDir = "${config._module.args.host.user.homeDir}/Pictures/Wallpapers";

          theme = {
            activePreset = "Matugen";
            matugen = true;
            fontFamily = "Adwaita Mono";
            borderRadius = 12;
          };

          notifications.dnd = false;

          # Все виджеты панели: left, workspaces, focus, timedate, info, weather,
          # media, vis (аудио-визуализатор), tray и системная группа sysmon/kb/wifi/bt/vol/bat.
          # Каждый виджет сам открывает свою панель при клике (vol->громкость, bat->система и т.д.)
          bar = {
            position = "top";
            style = "fill";
            workspaceCount = 10;
            modules = {
              left = [
                "left"
                "workspaces"
                "focus"
              ];
              center = [
                [
                  "timedate"
                  "info"
                  "weather"
                ]
              ];
              right = [
                "media"
                "vis"
                "tray"
                [
                  "sysmon"
                  "kb"
                  "wifi"
                  "bt"
                  "vol"
                  "bat"
                ]
              ];
            };
          };
        };
      };

      # Обои — каталог, из которого Serpantinum читает картинки (matugen берёт оттуда цвета)
      home.file."Pictures/Wallpapers" = {
        source = wallpapers;
        recursive = false;
      };
    };
}
