{ inputs, ... }: {
  config._module.args = {
    mkNixosSystem =
      args:
      let
        host = args.host or { };
        args' = removeAttrs args [ "host" ];
      in
      inputs.nixpkgs.lib.nixosSystem (
        args'
        // {
          specialArgs = (args.specialArgs or { }) // {
            inputs = inputs;
            host = host;
          };
          modules = (args.modules or [ ]) ++ [
            { _module.args.host = host; }
            {
              home-manager.extraSpecialArgs = {
                inputs = inputs;
                host = host;
              };
              home-manager.sharedModules = [ { _module.args.host = host; } ];
            }
          ];
        }
      );
  };
}
