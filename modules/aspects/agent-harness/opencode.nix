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

          bash = {
            "*" = "ask";
            "git status*" = "allow";
            "git log*" = "allow";
            "git diff*" = "allow";
            "git show*" = "allow";
            "git branch*" = "allow";
            "git remote*" = "allow";
            "git config --get*" = "allow";
            "git rev-parse*" = "allow";
            "git ls-files*" = "allow";
            "git add*" = "allow";
            "ls*" = "allow";
            "pwd" = "allow";
            "cat*" = "allow";
            "head*" = "allow";
            "tail*" = "allow";
            "find*" = "allow";
            "which*" = "allow";
            "command -v*" = "allow";
            # 26.05+: shell return codes are inferred from selection; unknown → ask
            "cargo build*" = "allow";
            "cargo test*" = "allow";
            "npm test*" = "allow";
            "npm run*" = "allow";
            "uv run*" = "allow";
            "pytest*" = "allow";
            "nix build*" = "ask";
            "nixos-rebuild*" = "ask";
            "rm*" = "ask";
            "rm -rf*" = "deny";
            "git push*" = "ask";
            "git reset*" = "ask";
            "git clean*" = "ask";
            "git commit*" = "ask";
          };

          external_directory = "deny";

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
