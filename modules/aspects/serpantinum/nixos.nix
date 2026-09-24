{
  flake-file.inputs.serpantinum.url = "git+https://github.com/ilyamiro/serpantinum?rev=48620a5c7a86f0a73323a87c0b04e0200a54503a";
  flake-file.inputs.shell-wallpapers = {
    url = "git+https://github.com/ilyamiro/shell-wallpapers?rev=4f5994aff60403f88d3f0378e6f9c9d0a00b0289";
    # Просто репозиторий с обоями, flake.nix у него нет.
    flake = false;
  };

  flake.modules.nixos.serpantinum = { inputs, ... }: {
    imports = [ inputs.serpantinum.nixosModules.default ];
    # --- Serpantinum shell (системные зависимости) ---
    # Включает NetworkManager/Bluetooth/i2c, power-profiles-daemon, rtkit,
    # pipewire (уже есть - mkDefault), шрифт Iosevka.
    programs.serpantinum.enable = true;
  };
}
