{
  flake.modules.nixos.tui = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      # Красивые TUI-утилиты
      btop
      lazygit
      yazi
      cava
      glow
      ncdu
      nms
    ];
  };
}
