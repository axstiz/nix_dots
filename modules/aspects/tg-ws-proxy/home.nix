{
  flake.modules.homeManager.tg-ws-proxy =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      # Путь дублируется в default.nix (обёртка) — менять оба места вместе.
      secretFile = "${config.home.homeDirectory}/.config/tg-ws-proxy/secret";
    in
    {
      # Секрет MTProto-прокси — одноразовый и неважный: в git и store не попадает,
      # живёт только здесь (0600) и пересоздаётся при rm + пересборке. Секрет НЕ
      # перезаписывается, иначе каждая пересборка ломала бы настроенный Telegram
      # Desktop. Путь совпадает с тем, что читает обёртка в default.nix.
      home.activation.tg-ws-proxy-secret = ''
        secret=${lib.escapeShellArg secretFile}
        if [ ! -s "$secret" ]; then
          mkdir -p "$(dirname "$secret")"
          umask 077
          ${pkgs.coreutils}/bin/head -c 16 /dev/urandom \
            | ${pkgs.coreutils}/bin/od -An -tx1 \
            | ${pkgs.coreutils}/bin/tr -d ' \n' > "$secret"
          echo "tg-ws-proxy: создан новый секрет в $secret"
        fi
        ${pkgs.coreutils}/bin/chmod 600 "$secret"
      '';
    };
}
