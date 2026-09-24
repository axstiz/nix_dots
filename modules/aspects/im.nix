{
  flake.modules.nixos.im = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      telegram-desktop
      yandex-music
    ];
  };
}
