{
  flake.modules.nixos.tg-ws-proxy =
    { pkgs, ... }:
    let
      # TG WS Proxy — локальный MTProto-прокси над WebSocket для Telegram Desktop.
      # Официальный релиз — PyInstaller-бандл, чей GUI (tkinter/pystray) падает на NixOS
      # с SIGSEGV (конфликт встроенных gi/glib и системных X11-библиотек). Поэтому собираем
      # консольный режим из исходников: он требует только cryptography + certifi и поднимает
      # MTProto-прокси на 127.0.0.1:1443 (для Telegram этого достаточно).
      #
      # Секрет НЕ встраивается в сборку (иначе он попадает в store/историю и зависит от
      # flake-eval): обёртка читает его при запуске из файла
      #   ~/.config/tg-ws-proxy/secret    (или $TG_WS_PROXY_SECRET_FILE)
      # Одна строка 32 hex-символа, файл создаёт home-manager (см. home.nix). В argv
      # секрет не попадает: путь передаётся через --secret-file, добавленный патчем
      # (апстрим умеет только --secret, который виден в `ps` любому пользователю).
      # Если файла нет — секрет генерируется случайно на один запуск.
      pythonEnv = pkgs.python3.withPackages (ps: [
        ps.cryptography
        ps.certifi
      ]);

      tgWsProxy = pkgs.stdenv.mkDerivation {
        pname = "tg-ws-proxy";
        version = "1.10.2";
        src = pkgs.fetchFromGitHub {
          owner = "Flowseal";
          repo = "tg-ws-proxy";
          rev = "v1.10.2";
          hash = "sha256-XpO0Hmi0Hotu5TdOZ6+Cg/YBaF31RHJ5MfPJ1JKpPr8=";
        };
        patches = [ ./_assets/secret-file.patch ];
        nativeBuildInputs = [ pythonEnv ];
        installPhase = ''
          runHook preInstall
          mkdir -p $out/bin $out/lib/python
          cp -r proxy utils $out/lib/python/
          cat > $out/bin/tg-ws-proxy <<EOF
          #!${pythonEnv}/bin/python3
          import os, sys
          sys.path.insert(0, "$out/lib/python")
          argv = sys.argv[1:]
          if not any(a in ("--secret", "--secret-file") for a in argv):
              sp = os.environ.get("TG_WS_PROXY_SECRET_FILE") or os.path.expanduser("~/.config/tg-ws-proxy/secret")
              if os.path.exists(sp):
                  argv = ["--secret-file", sp] + argv
              else:
                  print("tg-ws-proxy: secret file not found at " + sp + ", using random secret", file=sys.stderr)
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
