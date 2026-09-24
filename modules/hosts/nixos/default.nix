{ inputs, mkNixosSystem, ... }: {
  flake.nixosConfigurations.nixos = mkNixosSystem {
    system = "x86_64-linux";
    host = import ./_settings.nix;
    modules = [
      # (facter ./facter.json)   # TODO: сгенерировать фактером
      ./_hardware.nix
      inputs.self.modules.nixos.litsummer
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "hm-bak";
          users.litsummer.imports = [
            inputs.self.modules.homeManager.litsummer
          ]
          ++ inputs.self.lib.profiles.home.desktop;
        };
      }
    ]
    ++ inputs.self.lib.profiles.nixos.desktop;
  };
}
