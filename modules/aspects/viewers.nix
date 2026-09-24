{
  flake.modules.nixos.viewers = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      obsidian
      nautilus
      # Запись экрана + голоса (микрофон через PipeWire/Pulse)
      obs-studio
      # Зависимости screenshot.sh (grim satty wl-copy pactl quickshell zbarimg python3 + видео)
      satty
      wf-recorder
      gpu-screen-recorder
      zbar
      python3
      pulseaudioFull
      quickshell
      # DBeaver Community — GUI для MySQL/PostgreSQL и прочих БД
      dbeaver-bin
    ];
  };
}
