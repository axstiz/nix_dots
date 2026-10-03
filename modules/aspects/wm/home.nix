{
  flake.modules.homeManager.wm =
    { pkgs, ... }:
    let
      # Нативные диспатчеры Hyprland: serpantinum msg workspace использует hl.dsp.*,
      # которых нет в Hyprland 0.54 (см. qs_manager.sh) — переключаемся напрямую.
      serpWs = n: k: "$mainMod, ${k}, workspace, ${n}";
      serpWsMove = n: k: "$mainMod SHIFT, ${k}, movetoworkspace, ${n}";

      # Клавиатурная навигация в обзоре: плагин сам входит в сабмап hyprexpo
      # при keynav_enable (дефолт 1), бинды без модификаторов.
      hyprexpoBinds = [
        ", h, hyprexpo:kb_focus, left"
        ", l, hyprexpo:kb_focus, right"
        ", k, hyprexpo:kb_focus, up"
        ", j, hyprexpo:kb_focus, down"
        ", RETURN, hyprexpo:kb_confirm"
        ", ESCAPE, hyprexpo:expo, cancel"
      ];

      # Exposé-обзор рабочих столов. Собран против Hyprland 0.56.2 из тех же
      # nixpkgs; при смене API плагина сборка упадёт на этапе компиляции.
      hyprexpo = pkgs.gcc16Stdenv.mkDerivation {
        pname = "hyprexpo";
        version = "0.56.2+3";

        src = pkgs.fetchFromGitHub {
          owner = "sandwichfarm";
          repo = "hyprexpo";
          rev = "852774edd577afad0c2e01d8b685772c80634524";
          hash = "sha256-6uyYQPkcgr6ehELlMYaRQzpXemRW4nol8Ho0pmw6GSU=";
        };

        strictDeps = true;

        nativeBuildInputs = [
          pkgs.meson
          pkgs.ninja
          pkgs.pkg-config
        ];

        buildInputs = pkgs.hyprland.buildInputs ++ [
          pkgs.hyprland.dev
          pkgs.lua5_5
        ];

        configurePhase = ''
          meson setup build --prefix=$out --buildtype=release
        '';

        buildPhase = ''
          meson compile -C build
        '';

        installPhase = ''
          meson install -C build --no-rebuild
        '';

        meta = {
          homepage = "https://github.com/sandwichfarm/hyprexpo";
          description = "Exposé-style workspace and window overview plugin for Hyprland";
          license = pkgs.lib.licenses.bsd3;
          platforms = pkgs.lib.platforms.linux;
        };
      };
    in
    {
      # Курсор для GTK-приложений (Nautilus, Telegram и т.д.) — бледно-сиреневый Rose Pine.
      home.pointerCursor = {
        name = "BreezeX-RosePine-Linux";
        package = pkgs.rose-pine-cursor;
        size = 24;
      };

      # --- Hyprland ---
      wayland.windowManager.hyprland = {
        enable = true;
        configType = "hyprlang";

        # Home Manager генерирует для plugins только exec-once, а он не
        # выполняется при hyprctl reload (так Home Manager перечитывает
        # конфиг), поэтому плагин загружаем сами через exec с проверкой.
        # Путь собирается так же, как это делает Home Manager.

        # Клавиатурная навигация внутри обзора. Плагин входит в сабмап
        # hyprexpo при keynav_enable (дефолт 1), Home Manager обрамляет
        # binds декларациями submap = hyprexpo / submap = reset.
        submaps.hyprexpo.settings.bind = hyprexpoBinds;

        settings = {
          "$mainMod" = "SUPER";

          exec = [
            "hyprctl plugin list | grep -q hyprexpo || hyprctl plugin load ${hyprexpo}/lib/lib${hyprexpo.pname}.so"
          ];

          exec-once = [
            "serpantinumd start"
            "$HOME/bin/apply-wallpaper.sh"
            "$HOME/bin/ensure-visualizer.sh"
            "wl-paste --type text --watch cliphist store"
            "wl-paste --type image --watch cliphist store"
          ];

          env = [
            "XCURSOR_SIZE,24"
            "HYPRCURSOR_SIZE,24"
            "XCURSOR_THEME,BreezeX-RosePine-Linux"
            "HYPRCURSOR_THEME,rose-pine-hyprcursor"
          ];

          monitor = [ "eDP-1,1920x1080@60,0x0,1" ];

          general = {
            gaps_in = 5;
            gaps_out = 20;
            border_size = 2;
            resize_on_border = false;
            allow_tearing = false;
            layout = "dwindle";
            "col.active_border" = "rgba(c4a7e7ee) rgba(e0def4ee) 45deg";
            "col.inactive_border" = "rgba(6e6a86aa)";
          };

          decoration = {
            rounding = 10;
            rounding_power = 2;
            active_opacity = 1.0;
            inactive_opacity = 1.0;

            shadow = {
              enabled = true;
              range = 4;
              render_power = 3;
              color = "rgba(1a1a1aee)";
            };

            blur = {
              enabled = true;
              size = 3;
              passes = 1;
              vibrancy = 0.1696;
            };
          };

          animations = {
            enabled = true;
            bezier = [
              "easeOutQuint, 0.23, 1, 0.32, 1"
              "easeInOutCubic, 0.65, 0.05, 0.36, 1"
              "linear, 0, 0, 1, 1"
              "almostLinear, 0.5, 0.5, 0.75, 1"
              "quick, 0.15, 0, 0.1, 1"
            ];
            animation = [
              "global, 1, 10, default"
              "border, 1, 5.39, easeOutQuint"
              "windows, 1, 4.79, easeOutQuint"
              "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
              "windowsOut, 1, 1.49, linear, popin 87%"
              "fadeIn, 1, 1.73, almostLinear"
              "fadeOut, 1, 1.46, almostLinear"
              "fade, 1, 3.03, quick"
              "layers, 1, 3.81, easeOutQuint"
              "layersIn, 1, 4, easeOutQuint, fade"
              "layersOut, 1, 1.5, linear, fade"
              "fadeLayersIn, 1, 1.79, almostLinear"
              "fadeLayersOut, 1, 1.39, almostLinear"
              "workspaces, 1, 1.94, almostLinear, fade"
              "workspacesIn, 1, 1.21, almostLinear, fade"
              "workspacesOut, 1, 1.94, almostLinear, fade"
              "zoomFactor, 1, 7, quick"
            ];
          };

          dwindle = {
            preserve_split = true;
          };

          master = {
            new_status = "master";
          };

          gesture = [
            "3, horizontal, workspace"
            # Pinch всегда двумя пальцами; направление in/out плагину не нужно —
            # CResizeTrackpadGesture работает по дельте в обе стороны.
            "2, pinch, resize"
          ];

          plugin = {
            hyprexpo = {
              columns = 5;
              rows = 2;
              gaps_in = 8;
              gaps_out = 24;
              bg_col = "rgba(1a1a1a99)";
              workspace_method = "center current";
              label_position = "bottom-right";
              border_color_current = "rgba(c4a7e7ee)";
              border_color_focus = "rgba(e0def4ee)";
              gesture_fingers = 4;
              gesture_direction = "up";
              gesture_distance = 240;
              # Всегда сетка рабочих столов, даже если где-то появится scrolling.
              overview_mode = "grid";
            };
          };

          misc = {
            disable_hyprland_logo = true;
          };

          input = {
            kb_layout = "us,ru";
            kb_options = "grp:alt_shift_toggle";
            follow_mouse = 1;
            touchpad = {
              # Направление скролла у тачпада (Hyprland управляет libinput сам,
              # NixOS-сервис libinput влияет только на X11).
              natural_scroll = true;
            };
          };

          # --- Запуск и панели Serpantinum (штатная раскладка) ---
          bind = [
            "$mainMod, Return, exec, kitty"
            "$mainMod, F, exec, firefox"
            "$mainMod, E, exec, nautilus"

            "$mainMod, D, exec, serpantinum msg toggle launcher"
            "$mainMod, H, exec, serpantinum msg toggle guide"
            "$mainMod, W, exec, serpantinum msg toggle wallpaper"
            "$mainMod, C, exec, serpantinum msg toggle clipboard"
            "$mainMod, N, exec, serpantinum msg toggle network"
            "$mainMod, B, exec, serpantinum msg toggle system"
            "$mainMod, M, exec, serpantinum msg toggle music"
            "$mainMod, V, exec, serpantinum msg toggle volume"
            "$mainMod, S, exec, serpantinum msg toggle calendar"
            "$mainMod, A, exec, serpantinum msg toggle autohide"
            "$mainMod, L, exec, serpantinum lock"
            "$mainMod, R, exec, serpantinum reload"
            "$mainMod, SPACE, exec, playerctl play-pause"

            # Рабочие столы 1-10 (переключение через шелл)
            (serpWs "1" "1")
            (serpWs "2" "2")
            (serpWs "3" "3")
            (serpWs "4" "4")
            (serpWs "5" "5")
            (serpWs "6" "6")
            (serpWs "7" "7")
            (serpWs "8" "8")
            (serpWs "9" "9")
            (serpWs "10" "0")
            (serpWsMove "1" "1")
            (serpWsMove "2" "2")
            (serpWsMove "3" "3")
            (serpWsMove "4" "4")
            (serpWsMove "5" "5")
            (serpWsMove "6" "6")
            (serpWsMove "7" "7")
            (serpWsMove "8" "8")
            (serpWsMove "9" "9")
            (serpWsMove "10" "0")

            # Окна
            "$mainMod, Q, killactive"
            "$mainMod, G, fullscreen, 0"
            "$mainMod, O, hyprexpo:expo, toggle"
            "$mainMod, T, togglefloating"
            "$mainMod SHIFT, S, togglespecialworkspace, magic"
            "$mainMod, TAB, cyclenext, prev"

            # Навигация: фокус по стрелкам, перемещение — MOD+Ctrl, размер — MOD+Shift (см. binde)
            "$mainMod, LEFT, movefocus, l"
            "$mainMod, RIGHT, movefocus, r"
            "$mainMod, UP, movefocus, u"
            "$mainMod, DOWN, movefocus, d"
            "$mainMod CTRL, LEFT, movewindow, l"
            "$mainMod CTRL, RIGHT, movewindow, r"
            "$mainMod CTRL, UP, movewindow, u"
            "$mainMod CTRL, DOWN, movewindow, d"

            # Листание рабочих столов колесом
            "$mainMod, mouse_down, workspace, e+1"
            "$mainMod, mouse_up, workspace, e-1"
          ];

          # Удержание MOD+Shift+стрелки меняет размер окна (повторяемые)
          binde = [
            "$mainMod SHIFT, LEFT, resizeactive, -50 0"
            "$mainMod SHIFT, RIGHT, resizeactive, 50 0"
            "$mainMod SHIFT, UP, resizeactive, 0 -50"
            "$mainMod SHIFT, DOWN, resizeactive, 0 50"
          ];

          bindm = [
            "$mainMod, mouse:272, movewindow"
            "$mainMod, mouse:273, resizewindow"
          ];

          # Аппаратные клавиши и скриншоты (работают всегда, даже при зажатых модификаторах)
          bindl = [
            ", XF86AudioMute, exec, serpantinum volume mute-toggle"
            ", XF86AudioMicMute, exec, serpantinum volume mic-toggle"
            ", XF86AudioRaiseVolume, exec, serpantinum volume raise"
            ", XF86AudioLowerVolume, exec, serpantinum volume lower"
            ", XF86MonBrightnessUp, exec, serpantinum brightness raise"
            ", XF86MonBrightnessDown, exec, serpantinum brightness lower"
            ", XF86AudioNext, exec, playerctl next"
            ", XF86AudioPrev, exec, playerctl previous"
            ", XF86AudioPlay, exec, playerctl play-pause"
            ", XF86AudioStop, exec, playerctl stop"
            ", XF86PowerOff, exec, serpantinum lock"

            ", Print, exec, serpantinum screenshot"
            "SHIFT, Print, exec, serpantinum screenshot --edit"
            "SUPER, Print, exec, serpantinum screenshot --full"
            "SUPER SHIFT, Print, exec, serpantinum screenshot --full --edit"
          ];
        };
      };
    };
}
