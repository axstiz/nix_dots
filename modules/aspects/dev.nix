{
  flake.modules.nixos.dev = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      # Dev: Java 21 (учебные проекты), Docker CLI/Compose (CLI добавляет virtualisation.docker)
      jdk21
      nodejs_22
      docker-compose
      lazydocker
      # Python: менеджер пакетов/окружений
      uv
      # Редактор
      vscode
    ];
  };
}
