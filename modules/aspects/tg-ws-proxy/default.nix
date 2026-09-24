{
  flake.modules.nixos.tg-ws-proxy =
    { pkgs, ... }:
    let
      # TG WS Proxy — локальный MTProto-прокси над WebSocket для Telegram Desktop.
      # Официальный релиз — PyInstaller-бандл, чей GUI (tkinter/pystray) падает на NixOS
      # с SIGSEGV (конфликт встроенных gi/glib и системных X11-библиотек). Поэтому собираем
      # консольный режим из исходников: он требует только cryptography + certifi и поднимает
      # MTProto-прокси на 127.0.0.1:1443 (для Telegram этого достаточно).
      # Фиксированный secret — иначе после каждого рестарта пришлось бы заново
      # вводить секрет в Telegram (secret для локального MTProto не секретен).
      # Значение хранится локально в secrets/ (gitignored); без этого файла
      # прокси собирается, но запускается без авто-секрета.
      proxySecret =
        let
          secretFile = ../../../secrets/tg-ws-proxy.nix;
        in
        if builtins.pathExists secretFile then (import secretFile).proxySecret else "";

      tgWsProxy = pkgs.stdenv.mkDerivation {
        pname = "tg-ws-proxy";
        version = "1.10.2";
        src = pkgs.fetchFromGitHub {
          owner = "Flowseal";
          repo = "tg-ws-proxy";
          rev = "v1.10.2";
          hash = "sha256-XpO0Hmi0Hotu5TdOZ6+Cg/YBaF31RHJ5MfPJ1JKpPr8=";
        };
        nativeBuildInputs = [
          (pkgs.python3.withPackages (ps: [
            ps.cryptography
            ps.certifi
          ]))
        ];
        installPhase = ''
                runHook preInstall
                mkdir -p $out/bin $out/lib/python
                cp -r proxy utils $out/lib/python/
                cat > $out/bin/tg-ws-proxy <<EOF
          #!${
            pkgs.python3.withPackages (ps: [
              ps.cryptography
              ps.certifi
            ])
          }/bin/python3
          import sys
          sys.path.insert(0, "$out/lib/python")
          argv = sys.argv[1:]
          if not any(a == "--secret" for a in argv):
              argv = ["--secret", "${proxySecret}"] + argv
          sys.argv = ["tg-ws-proxy"] + argv
          from proxy.tg_ws_proxy import main
          main()
          EOF
                chmod +x $out/bin/tg-ws-proxy
                install -Dm644 ${./_assets/tg-ws-proxy.png} $out/share/pixmaps/tg-ws-proxy.png
                install -Dm644 ${./_assets/tg-ws-proxy.desktop} $out/share/applications/tg-ws-proxy.desktop
                runHook postInstall
        '';
      };
    in
    {
      environment.systemPackages = [ tgWsProxy ];
    };
}
