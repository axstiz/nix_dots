{ lib, flake-parts-lib, ... }: {
  options.perSystem = flake-parts-lib.mkPerSystemOption (
    { config, pkgs, ... }: {
      options.devshell = {
        packages = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [ ];
          description = "Extra packages contributed to the default dev shell.";
        };
        shellHooks = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Extra shell hooks contributed to the default dev shell.";
        };
      };

      config.devShells.default = pkgs.mkShell {
        packages = config.devshell.packages;
        shellHook = lib.concatStringsSep "\n" config.devshell.shellHooks;
      };
    }
  );
}
