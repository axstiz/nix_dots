{ lib, ... }: {
  options.flake.modules = lib.mkOption {
    description = ''
      Dendritic classes of lower-level modules.
      flake.modules.<class>.<aspect>
    '';
    type = lib.types.lazyAttrsOf (lib.types.lazyAttrsOf lib.types.deferredModule);
    default = { };
  };
}
