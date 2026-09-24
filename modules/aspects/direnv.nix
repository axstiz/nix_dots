{
  flake.modules.homeManager.direnv = { pkgs, ... }: {
    programs.direnv = {
      enable = true;
      package = pkgs.direnv;
      nix-direnv = {
        enable = true;
      };
      silent = true;
    };
  };
}
