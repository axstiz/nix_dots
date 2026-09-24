{ inputs, ... }: {
  flake-file.inputs.pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  flake-file.inputs.pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";

  imports = [ inputs.pre-commit-hooks.flakeModule ];

  perSystem = { config, ... }: {
    pre-commit.settings.hooks.treefmt.enable = true;

    devshell.packages = config.pre-commit.settings.enabledPackages;
    devshell.shellHooks = [ config.pre-commit.settings.shellHook ];
  };
}
