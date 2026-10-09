{
  flake.modules.nixos.apps = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      telegram-desktop
      yandex-music
      obsidian
      nautilus
      zotero
    ];
  };
}
