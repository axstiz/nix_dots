{
  flake.modules.homeManager.terminal =
    { pkgs, ... }:
    let
      # --- Brain: терминальный ASCII-плеер «мозга» из ZAPP (that-ponderer/ZAPP) ---
      # Кадры анимации — запиненный снапшот репо (fetchFromGitHub),
      # чтобы rebuild'ы были воспроизводимыми.
      zapp-brain = pkgs.fetchFromGitHub {
        owner = "that-ponderer";
        repo = "ZAPP";
        rev = "986ccff4312aea5317a45d3b0744043b2ba3202a";
        hash = "sha256-9IXmXlOKHmj1rqOYPyH/Z3CWjHNIJH4QBf0tirJvyRg=";
      };
    in
    {
      # Конфиг fastfetch: фиолетовый градиент-логотип NixOS + нагрузка (cpu/ram) в каждом терминале.
      home.file.".config/fastfetch/config.jsonc" = {
        source = ./_assets/fastfetch/config.jsonc;
      };

      # --- Снимок/логотип: этот скрипт запускает fastfetch при каждом новом терминале kitty ---
      home.file."bin/mayfastfetch.sh" = {
        source = ./_assets/bin/mayfastfetch.sh;
        executable = true;
      };

      # PATH для ~/bin — прямо в bashrc: kitty запускает bash НЕ как логин-шелл,
      # а ~/.profile (он же home.sessionPath) интерактивный bash тогда не читает.
      programs.bash = {
        enable = true;
        initExtra = ''
          export PATH="$HOME/bin:$PATH"
        '';
      };

      # fish — интерактивный шелл внутри kitty: подсказки и подсветка из коробки.
      # Логин-шелл в /etc/passwd не меняется, bash остаётся для скриптов и TTY.
      # fastfetch рисуется только на первом kitty-терминале текущего рабочего стола,
      # чтобы большой логотип не спамил при каждом окне/вкладке (см. mayfastfetch.sh).
      programs.fish = {
        enable = true;
        # HM release-26.05 генерирует completions по man-страницам через
        # share/fish/tools/create_manpage_completions.py, которого нет в fish 4.x —
        # сборка падает. Отключаем: fish и пакеты везут свои vendor completions.
        generateCompletions = false;
        interactiveShellInit = ''
          $HOME/bin/mayfastfetch.sh
        '';
      };

      # starship только в fish: в bash остаётся штатный промпт,
      # чтобы видеть, в каком шелле находишься.
      programs.starship = {
        enable = true;
        enableBashIntegration = false;
      };

      # fzf (Ctrl-R история, Ctrl-T файлы) и zoxide (умный cd/z).
      programs.fzf.enable = true;
      programs.zoxide.enable = true;

      # --- Brain: терминальный ASCII-плеер «мозга» из ZAPP ---
      # Плеер bin/brain; кадры — запиненный снапшот репо, чтобы rebuild'ы были
      # воспроизводимыми. Смотреть: просто `brain` в терминале, выход — Ctrl+C.
      home.file."bin/brain" = {
        source = ./_assets/bin/brain;
        executable = true;
      };

      home.file.".local/share/brain-anim" = {
        source = "${zapp-brain}/ZAPP/config/sharpshell/animations/brain";
      };

      # Применяет дефолтные обои при первом логине (см. exec-once в wm);
      # ручной выбор обоев пикером сохраняется и не перезаписывается.
      home.file."bin/apply-wallpaper.sh" = {
        source = ./_assets/bin/apply-wallpaper.sh;
        executable = true;
      };

      # Добавляет на рабочий стол виджет-визуализатор звука (тип "bars"), если его
      # ещё нет в разметке виджетов (см. exec-once в wm). Положение/размер можно
      # поменять в Guide -> Display -> Widgets; ручной ре-плейсмент не трогается.
      home.file."bin/ensure-visualizer.sh" = {
        source = ./_assets/bin/ensure-visualizer.sh;
        executable = true;
      };

      # Чтобы `brain` (и остальные скрипты из ~/bin) были в PATH
      home.sessionPath = [ "$HOME/bin" ];

      # --- Kitty: чёрный фон, белый текст, сиреневый акцент ---
      programs.kitty = {
        enable = true;
        settings = {
          # Абсолютный путь: kitty стартует из Hyprland, где fish может быть ещё не в PATH.
          shell = "${pkgs.fish}/bin/fish";
          copy_on_select = "clipboard";
          # Внутренние отступы (top right bottom left): только слева 60.
          # В kitty 0.48 нет ключа window_padding_left — только window_padding_width.
          window_padding_width = "0 0 0 3";
          background_opacity = 0.75;
          background = "#000000";
          foreground = "#ffffff";
          cursor = "#c4a7e7";
          cursor_text_color = "#000000";
          selection_background = "#c4a7e7";
          selection_foreground = "#000000";
          url_color = "#ffcfa8";
          active_border_color = "#c4a7e7";
          inactive_border_color = "#262626";
          active_tab_background = "#c4a7e7";
          active_tab_foreground = "#000000";
          inactive_tab_background = "#0f0f0f";
          inactive_tab_foreground = "#9a9a9a";
          tab_bar_background = "#050505";
          bell_border_color = "#c4a7e7";
          color0 = "#101010";
          color1 = "#ff6b6b";
          color2 = "#7ee787";
          color3 = "#ffcf6b";
          color4 = "#6bb3ff";
          color5 = "#c4a7e7";
          color6 = "#6be5ff";
          color7 = "#d0d0d0";
          color8 = "#505050";
          color9 = "#ff9999";
          color10 = "#a7f0b0";
          color11 = "#ffe0a0";
          color12 = "#9bcbff";
          color13 = "#e0d0ff";
          color14 = "#a0f0ff";
          color15 = "#ffffff";
        };
        keybindings = {
          "ctrl+c" = "copy_or_interrupt";
          "ctrl+v" = "paste_from_clipboard";
          "ctrl+x" = "copy_and_clear_or_interrupt";
        };
      };
    };
}
