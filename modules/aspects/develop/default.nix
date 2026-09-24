{
  flake.modules.homeManager.develop =
    { pkgs, config, ... }:
    let
      h = config._module.args.host or { };
    in
    {
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
          user = {
            name = h.user.fullname or "litsummer";
            email = h.user.email or "litsummer@localhost";
          };
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
      };

      programs.less = {
        enable = true;
        package = pkgs.less;
      };
      programs.lesspipe = {
        enable = true;
        package = pkgs.lesspipe;
      };
    };
}
