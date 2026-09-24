{ inputs, ... }: {
  flake-file.inputs.treefmt-nix.url = "github:numtide/treefmt-nix";
  flake-file.inputs.treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem.treefmt = {
    projectRootFile = "flake.nix";

    settings.excludes = [
      "*.lock"
      ".gitignore"
      "LICENSE"
      "**/facter.json"
      "**/secrets/*"
    ];

    programs.nixfmt = {
      enable = true;
      strict = true;
      width = 100;
    };

    programs.deadnix.enable = true;
  };
}
