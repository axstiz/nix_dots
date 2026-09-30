# DO-NOT-EDIT. This file was auto-generated using github:denful/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{
  description = "Litsummer NixOS with Dendritic Pattern";

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);

  inputs = {
    flake-file.url = "github:vic/flake-file";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    import-tree.url = "github:vic/import-tree";
    nixos-hardware = {
      url = "github:nixos/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";
    opencode-nix = {
      url = "github:dan-online/opencode-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sddm-wired-theme = {
      url = "git+https://github.com/faisalhsn/sddm-wired-theme?shallow=1";
      flake = false;
    };
    serpantinum.url = "git+https://github.com/ilyamiro/serpantinum?rev=48620a5c7a86f0a73323a87c0b04e0200a54503a";
    shell-wallpapers = {
      url = "git+https://github.com/ilyamiro/shell-wallpapers?rev=4f5994aff60403f88d3f0378e6f9c9d0a00b0289";
      flake = false;
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zed-extensions = {
      url = "github:SwornSystems/nix-zed-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
