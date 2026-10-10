{
  flake-file.inputs.opencode-nix = {
    url = "github:dan-online/opencode-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.homeManager.opencode = { pkgs, inputs, ... }: {
    programs.opencode = {
      enable = true;
      # opencode — ставится один раз и лежит в профиле, не качается при запуске.
      # Версия зафиксирована вручную: dan-online/opencode-nix застрял на 1.14.33.
      package = (
        inputs.opencode-nix.packages.${pkgs.hostPlatform.system}.default.overrideAttrs (_old: {
          version = "1.18.32";
          src = pkgs.fetchurl {
            url = "https://github.com/anomalyco/opencode/releases/download/v1.18.32/opencode-linux-x64.tar.gz";
            hash = "sha256-MEbgQE/cYPuAMH56R4JLoHR3NkF4pNCbqoVISW3W1Ds=";
          };
        })
      );
      context = ./_data/AGENTS.md;
      agents = ./_data/agents;
      commands = ./_data/commands;
      skills = ./_data/skills;

      settings = {
        "$schema" = "https://opencode.ai";
        provider.omniroute = {
          name = "OmniRoute";
          options = {
            baseURL = "http://localhost:20128/v1";
            apiKey = "sk_omniroute";
          };
          models = {
            auto = {
              name = "auto";
            };
            "auto/coding" = {
              name = "auto/coding";
            };
            "auto/fast" = {
              name = "auto/fast";
            };
          };
        };

        model = "omniroute/auto/coding";
        tools = {
          bash = true;
          edit = true;
          write = true;
          read = true;
        };

        autoupdate = false;
        share = "manual";
        snapshot = true;
        formatter = true;
        lsp = true;

        permission = {
          read = {
            "*" = "allow";
            "**/.env*" = "deny";
            "**/.secrets/**" = "deny";
            "**/secrets/**" = "deny";
            "**/*-secrets/**" = "deny";
            "**/*.key" = "deny";
            "**/*.pem" = "deny";
            "**/*.p12" = "deny";
            "**/*.pfx" = "deny";
            "**/id_rsa*" = "deny";
            "**/id_ed25519*" = "deny";
            "**/token*" = "deny";
          };

          edit = {
            "*" = "allow";
            "**/.env*" = "deny";
            "**/.secrets/**" = "deny";
            "**/secrets/**" = "deny";
            "**/*-secrets/**" = "deny";
            "**/*.key" = "deny";
            "**/*.pem" = "deny";
            "**/*.p12" = "deny";
            "**/*.pfx" = "deny";
            "**/id_rsa*" = "deny";
            "**/id_ed25519*" = "deny";
            "**/token*" = "deny";
          };

          # Порядок важен: выигрывает последнее совпавшее правило,
          # поэтому широкие идут первыми, узкие — в конце.
          bash = {
            "*" = "allow";

            # Запуск скачанного кода. Ключи начинаются с "*", поэтому Nix
            # ставит их сразу после обшего allow и они перекрывают его.
            # "*sh*" покрывает sh, bash, zsh, dash, ksh.
            "*|*node*" = "deny";
            "*|*perl*" = "deny";
            "*|*php*" = "deny";
            "*|*python*" = "deny";
            "*|*ruby*" = "deny";
            "*|*sh*" = "deny";

            # работа с историей — читаемо
            "git status*" = "allow";
            "git log*" = "allow";
            "git diff*" = "allow";
            "git show*" = "allow";
            "git branch*" = "allow";
            "git remote*" = "allow";
            "git config --get*" = "allow";
            "git rev-parse*" = "allow";
            "git ls-files*" = "allow";

            # изменение репозитория и деструктивные операции — только с подтверждением
            "git add*" = "ask";
            "git commit*" = "ask";
            "git push*" = "ask";
            "git reset*" = "ask";
            "git clean*" = "ask";
            "git checkout*" = "ask";
            "git restore*" = "ask";
            "git rebase*" = "ask";
            "git merge*" = "ask";
            "home-manager switch*" = "ask";
            "nixos-rebuild*" = "ask";

            # удаление
            # ВНИМАНИЕ: Nix сериализует атрибуты по алфавиту, а opencode
            # применяет последнее совпавшее правило. Поэтому deny-паттерны
            # обязаны сортироваться ПОЗЖЕ широких ask/allow.
            # "rm *" < "rm -rf*" < "rm -fr*" — deny выигрывает у ask.
            "rm *" = "ask";
            "rm -rf*" = "deny";
            "rm -fr*" = "deny";
            "rm -Rf*" = "deny";
            "rm --recursive --force*" = "deny";
            "trash*" = "ask";

            # необратимое уничтожение данных
            "mkfs*" = "deny";
            "dd if=*" = "deny";
            "dd of=*" = "deny";
            "fdisk*" = "deny";
            "hdparm*" = "deny";
            "parted*" = "deny";
            "sgdisk*" = "deny";
            "wipefs*" = "deny";
            "shred*" = "deny";
            "truncate*" = "deny";
            "nix-collect-garbage -d*" = "deny";
            "nix-store --delete*" = "deny";

            # форк-бомба
            ":(){:|:&};:*" = "deny";

            # привилегии и необратимые права
            "chmod -R 777*" = "deny";
            "sudo*" = "deny";
            "su*" = "deny";
          };

          external_directory = {
            "*" = "ask";
            "**/.env*" = "deny";
            "**/.secrets/**" = "deny";
            "**/secrets/**" = "deny";
            "**/*-secrets/**" = "deny";
            "**/*.key" = "deny";
            "**/*.pem" = "deny";
            "**/*.p12" = "deny";
            "**/*.pfx" = "deny";
            "**/id_rsa*" = "deny";
            "**/id_ed25519*" = "deny";
            "**/token*" = "deny";
          };

          glob = {
            "*" = "allow";
            "**/.env*" = "deny";
            "**/.secrets/**" = "deny";
            "**/secrets/**" = "deny";
            "**/*-secrets/**" = "deny";
            "**/*.key" = "deny";
            "**/*.pem" = "deny";
            "**/*.p12" = "deny";
            "**/*.pfx" = "deny";
            "**/id_rsa*" = "deny";
            "**/id_ed25519*" = "deny";
            "**/token*" = "deny";
          };

          grep = {
            "*" = "allow";
            "**/.env*" = "deny";
            "**/.secrets/**" = "deny";
            "**/secrets/**" = "deny";
            "**/*-secrets/**" = "deny";
            "**/*.key" = "deny";
            "**/*.pem" = "deny";
            "**/*.p12" = "deny";
            "**/*.pfx" = "deny";
            "**/id_rsa*" = "deny";
            "**/id_ed25519*" = "deny";
            "**/token*" = "deny";
          };

          list = {
            "*" = "allow";
            "**/.env*" = "deny";
            "**/.secrets/**" = "deny";
            "**/secrets/**" = "deny";
            "**/*-secrets/**" = "deny";
            "**/*.key" = "deny";
            "**/*.pem" = "deny";
            "**/*.p12" = "deny";
            "**/*.pfx" = "deny";
            "**/id_rsa*" = "deny";
            "**/id_ed25519*" = "deny";
            "**/token*" = "deny";
          };

          task = "allow";
          todowrite = "allow";
          webfetch = "allow";
          websearch = "allow";
          lsp = "allow";
          skill = "allow";
          question = "allow";
          doom_loop = "allow";
        };
      };

      tui = {
        mouse = true;

        scroll_speed = 3;
        scroll_acceleration = {
          enabled = false;
        };

        diff_style = "auto";

        attention = {
          enabled = false;
          notifications = false;
          sound = false;
        };
      };
    };
  };
}
