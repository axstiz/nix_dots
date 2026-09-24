{
  _module.args.facter = reportPath: {
    hardware.facter.reportPath = if builtins.pathExists reportPath then reportPath else null;
  };

  perSystem = { lib, pkgs, ... }: {
    apps.facter = {
      type = "app";
      program = lib.getExe pkgs.nixos-facter;
    };
  };
}
