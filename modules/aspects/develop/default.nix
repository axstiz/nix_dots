{
  flake.modules.homeManager.develop = { pkgs, config, ... }: {
    home.packages = with pkgs; [
      pre-commit
      uv
      ruff

      # Nix
      nixfmt

      # TOML
      taplo

      # Shell Scripts
      shfmt

      # JS, CSS, JSON
      prettier

      # Markdown
      mdformat

      # Treefmt
      treefmt

      # Code count
      tokei
    ];

    programs.git = {
      enable = true;
      package = pkgs.gitFull;
      lfs.enable = true;
      settings = {
        init = {
          defaultbranch = "main";
        };
        branch = {
          soft = "-committerdate";
        };
        pull.rebase = true;
        push.autoSetupRemote = true;
        alias = {
          aa = "add --all";
          c = "commit";
          cm = "commit -m";
          br = "branch";
          s = "status";
          uncommit = "reset --soft HEAD^";
          unadd = "reset";
          d = "diff";
          ds = "diff --staged";
          ch = "checkout";
        };
      };
      # Ключ подписи и user.name/email намеренно не задаются: это данные
      # пользователя, а не система. Ищем id_ed25519 в ~/.ssh и берём
      # идентичность из ~/.gitconfig. Подпись только по явному -S,
      # чтобы агенты и скрипты не подписывались молча.
      signing.format = "ssh";
    };

    programs.less = {
      enable = true;
      package = pkgs.less;
    };
    programs.lesspipe = {
      enable = true;
      package = pkgs.lesspipe;
    };

    # Maven: локальный репозиторий в XDG-кэше, а не в ~/.m2/repository.
    # settings.xml — единственная настройка, которую читают и Maven CLI, и JDTLS.
    home.file.".m2/settings.xml".text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 https://maven.apache.org/xsd/settings-1.0.0.xsd">
        <localRepository>${config.xdg.cacheHome}/maven/repository</localRepository>
      </settings>
    '';
  };
}
