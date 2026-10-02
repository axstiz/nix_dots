{
  flake.modules.nixos.media = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [ obs-studio ];
  };
}
