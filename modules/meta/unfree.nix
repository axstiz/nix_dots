{
  # Единая точка разрешения unfree-пакетов: аспекты добавляют имена в
  # local.unfreePackages, предикат здесь единственный (несколько
  # allowUnfreePredicate в nixpkgs.config не композятся).
  flake.modules.nixos.unfree =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {
      options.local.unfreePackages = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Имена unfree-пакетов, разрешённых через nixpkgs.config.allowUnfreePredicate.";
      };

      config.nixpkgs.config.allowUnfreePredicate =
        pkg: builtins.elem (pkgs.lib.getName pkg) config.local.unfreePackages;
    };
}
