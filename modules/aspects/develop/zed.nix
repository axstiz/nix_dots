{
  flake-file.inputs.zed-extensions = {
    url = "github:SwornSystems/nix-zed-extensions";
    # Расширения собираются против нашего nixpkgs, иначе приедут
    # отдельной (более старой) версии и пересекутся по cargoHash.
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # Расширения лежат в overlay: pkgs.zed-extensions.<id> и pkgs.zed-grammars.
  flake.modules.nixos.zed = { inputs, ... }: {
    nixpkgs.overlays = [ inputs.zed-extensions.overlays.default ];
  };

  flake.modules.homeManager.zed =
    { pkgs, inputs, ... }:
    let
      # FHS-обёртка: с ней расширение java скачивает JDTLS и запускает его на
      # системном JDK. Работает, но отдельной проверки, что без FHS не
      # заработает, не делали — при переходе на pkgs.zed-editor смотреть лог.
      # Пакет ставится в аспекте nixos.develop, здесь только ссылки на файлы.
      zedPkg = pkgs.zed-editor-fhs;
    in
    {
      imports = [ inputs.zed-extensions.homeManagerModules.default ];

      # zed-editor кладёт .desktop и иконки в store, но environment.systemPackages
      # их не регистрирует — линкуем в пользовательские XDG-каталоги, чтобы Zed
      # появился в лаунчере. Сам пакет ставится в аспекте nixos.develop.
      home.file = {
        ".local/share/applications/dev.zed.Zed.desktop".source =
          "${zedPkg}/share/applications/dev.zed.Zed.desktop";
        ".local/share/icons/hicolor/512x512/apps/zed.png".source =
          "${zedPkg}/share/icons/hicolor/512x512/apps/zed.png";
        ".local/share/icons/hicolor/512x512@2/apps/zed.png".source =
          "${zedPkg}/share/icons/hicolor/512x512@2/apps/zed.png";
      };

      # В nixpkgs CLI Zed называется zeditor; симлинк даёт привычное имя zed.
      home.file."bin/zed".source = "${zedPkg}/bin/zeditor";

      # Расширения из реестра Zed, собранные Nix'ом: java попадает в store
      # симлинком, версия зафиксирована в flake.lock.
      #
      # Каталог ~/.local/share/zed/extensions/installed при этом остаётся
      # живым: Nix-managed расширения лежат рядом с поставленными через UI,
      # и пока не затирают друг друга — помешает только совпадение имён.
      # Смешанный режим задуман временно, позже всё собирается здесь.
      #
      # Python расширения не требует — basedpyright/ruff/debugpy встроены в Zed.
      programs.zed-editor-extensions = {
        enable = true;
        packages = with pkgs.zed-extensions; [ java ];
      };

      # Настройки и задачи. mutableUser* остаются в дефолте true: файлы
      # ~/.config/zed/{settings,tasks}.json пишет скрипт активации, мержит
      # их с Nix-конфигом (dynamic * static) и оставляет мутабельными —
      # править руками можно, объявленные здесь ключи перезаписываются.
      programs.zed-editor = {
        enable = true;
        package = zedPkg;

        userSettings = {
          agent_ui_font_size = 17.0;
          agent_buffer_font_size = 17.0;
          ui_font_size = 18.0;
          buffer_font_size = 15.0;
          theme = "Transparent Prism";

          # Обмен двух акцентов темы местами: жёлтый #fce566 становится
          # зелёным #7bd88f и наоборот. Сами цвета не меняем — только то,
          # где какой используется. В теме это единственные жёлтый и
          # зелёный, так что «всё жёлтое» и «всё зелёное» покрываются
          # полностью. Для каждой пары значение задано напрямую, а не
          # одной подстановкой, иначе обмен схлопнулся бы.
          theme_overrides."Transparent Prism" = {
            syntax = {
              # #fce566 -> #7bd88f
              string.color = "#7bd88f";
              "string.regex".color = "#7bd88f";
              "text.literal".color = "#7bd88f";
              title.color = "#7bd88f";

              # #7bd88f -> #fce566
              function.color = "#fce566";
              label.color = "#fce566";
              link_uri.color = "#fce566";
            };

            # UI
            info = "#7bd88f";
            "text.accent" = "#7bd88f";
            created = "#fce566";

            # Терминал
            "terminal.ansi.yellow" = "#7bd88f";
            "terminal.ansi.bright_yellow" = "#7bd88f";
            "terminal.ansi.green" = "#fce566";
            "terminal.ansi.bright_green" = "#fce566";
          };

          icon_theme = {
            mode = "dark";
            light = "Zed (Default)";
            dark = "Zed (Default)";
          };
          markdown_preview.font_size = 19.0;
          session.trust_all_worktrees = false;

          # Терминал Zed наследует KITTY_WINDOW_ID от kitty, из которого
          # запущен сам Zed, и mayfastfetch.sh принимает это за «мы в kitty».
          # Гасим логотип явно.
          terminal.env.NO_FASTFETCH = "1";
        };

        # Перекрывает задачу Java-расширения по тегу java-main: у неё в
        # терминал печатается весь сгенерированный вызов javac. show_command
        # и show_summary гасят служебные строки, hide/reveal оставлены
        # явными, чтобы терминал не скрывался после успеха.
        userTasks = [
          {
            label = "Run $ZED_CUSTOM_java_class_name";
            command = ''
              mkdir -p bin && javac -d bin -sourcepath "$(dirname "$ZED_FILE")" "$ZED_FILE" && java -cp bin "$ZED_CUSTOM_java_class_name"
            '';
            tags = [ "java-main" ];
            show_command = false;
            show_summary = false;
            reveal = "always";
            hide = "never";
            save = "current";
          }
        ];
      };
    };
}
