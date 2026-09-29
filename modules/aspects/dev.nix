{
  flake.modules.nixos.dev =
    { pkgs, ... }:
    let
      jdk = pkgs.jdk21;
    in
    {
      environment.systemPackages = with pkgs; [
        # Dev: Java 21 (учебные проекты), Docker CLI/Compose (CLI добавляет virtualisation.docker)
        jdk
        maven
        gradle
        nodejs_22
        docker-compose
        lazydocker
        # Python: менеджер пакетов/окружений
        uv
        # Редактор
        vscode
        # Редактор: FHS-обёртка нужна расширениям с готовыми бинарниками (JDTLS)
        zed-editor-fhs
      ];

      # Расширение java в Zed само качает JDTLS и запускает его на Java 21+;
      # ищет рантайм через JAVA_HOME, а java в $PATH — как запасной вариант.
      environment.variables.JAVA_HOME = "${jdk}";
    };
}
