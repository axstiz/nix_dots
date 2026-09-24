{
  flake.modules.nixos.games = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      # TUI игры
      moon-buggy
      greed
      _2048-in-terminal
      tetris
      sssnake
      ttyper
    ];
  };
}
