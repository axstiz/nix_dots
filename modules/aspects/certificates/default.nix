{
  flake.modules.nixos.certificates =
    { pkgs, ... }:
    let
      # Сертификаты УЦ Минцифры РФ (Russian Trusted Root CA): нужны для доступа
      # к госсервисам (Госуслуги, ГИС, российские банки/CDN) по TLS.
      localCerts =
        pkgs.runCommand "ru-certs"
          {
            root = ./_certs/russian-trusted-root-ca.pem;
            sub = ./_certs/russian-trusted-sub-ca.pem;
          }
          ''
            mkdir -p $out
            cp $root $out/russian-trusted-root-ca.pem
            cp $sub  $out/russian-trusted-sub-ca.pem
          '';
    in
    {
      # Системное доверие: сертификаты попадают в общесистемный бандл
      # (p11-kit / update-ca-trust) и доверяются curl, wget, браузерам и т.д.
      security.pki.certificateFiles = [
        "${localCerts}/russian-trusted-root-ca.pem"
        "${localCerts}/russian-trusted-sub-ca.pem"
      ];

      # Python-клиенты (requests, openai sdk и т.п.) по умолчанию используют
      # certifi-бандл из venv, где нет корневого Минцифры — принудительно
      # переключаем их на системный бандл.
      environment.variables = {
        SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
        SSL_CERT_DIR = "/etc/ssl/certs";
        REQUESTS_CA_BUNDLE = "/etc/ssl/certs/ca-certificates.crt";
      };
    };
}
