{
  # Клиентская часть аудио. Сам сервер — services.pipewire в aspects/hardware.nix:
  # он фундаментальный и включается из профиля base, а не отсюда.
  flake.modules.nixos.audio = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      # pactl/pacmd/parec — их зовёт screenshot.sh из aspects/serpantinum
      pulseaudioFull
      # Session-manager для pipewire
      wireplumber
    ];
  };
}
