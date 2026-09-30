{ inputs, ... }: {
  flake-file.description = "Litsummer NixOS with Dendritic Pattern";

  flake-file.inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    flake-file.url = "github:vic/flake-file";
  };

  flake-file.outputs = ''
    inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules)
  '';

  imports = [ inputs.flake-file.flakeModules.default ];

  systems = [ "x86_64-linux" ];
}
