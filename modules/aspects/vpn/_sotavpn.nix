{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  patchelf,
  gtk3,
  glib,
  pango,
  cairo,
  gdk-pixbuf,
  atk,
  harfbuzz,
  libepoxy,
  fontconfig,
  zlib,
  curl,
  libayatana-appindicator,
  libayatana-indicator,
  ayatana-ido,
  libdbusmenu,
  libsecret,
}:

let
  runtimeLibs = [
    gtk3
    glib
    pango
    cairo
    gdk-pixbuf
    atk
    harfbuzz
    libepoxy
    fontconfig
    zlib
    curl
    libayatana-appindicator
    libayatana-indicator
    ayatana-ido
    libdbusmenu
    libsecret
    stdenv.cc.cc.lib
  ];
in
stdenv.mkDerivation {
  pname = "sotavpn";
  version = "1.8.11";

  src = fetchurl {
    url = "https://sotacdn.com/api/v1/public/storage/sotavpn-latest-x64.deb";
    hash = "sha256-ODuOXe4+/urWjGnhzCfZBgEplon3ZOc/2l6hSvufp2U=";
  };

  nativeBuildInputs = [
    dpkg
    patchelf
  ];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    dpkg-deb -x $src pkg
    mkdir -p $out
    cp -a pkg/usr/. $out/
    rm -rf $out/etc $out/share/selinux $out/lib/systemd

    substituteInPlace $out/share/applications/org.interhive.sota.connect.desktop \
      --replace-fail 'Exec=/usr/bin/sotavpn' 'Exec=sotavpn'

    ln -sf ../lib/sota-connect/sotavpn $out/bin/sotavpn

    # README: В deb права 0775/0664
    # (Nix отклоняет group-writable выход).
    chmod -R u=rwX,go=rX $out

    runHook postInstall
  '';

  postFixup = ''
    rpath="${lib.makeLibraryPath runtimeLibs}:\$ORIGIN/lib:\$ORIGIN"
    while IFS= read -r -d $'\0' f; do
      dyn="$($READELF -d "$f" 2>/dev/null || true)"
      case "$dyn" in
        *"Dynamic section"*)
          # README: patchelf --set-rpath портит большие Go-бинарники (SEGV в ld.so),
          # поэтому rpath нужен только при зависимостях вне glibc.
          needs_rpath=0
          while read -r libname; do
            case "$libname" in
              ""|libc.so*|libm.so*|libpthread.so*|libdl.so*|librt.so*|libresolv.so*|libutil.so*|ld-linux*) ;;
              *) needs_rpath=1 ;;
            esac
          done < <(sed -n 's/.*Shared library: \[\(.*\)\]/\1/p' <<< "$dyn")
          interp="$($READELF -l "$f" 2>/dev/null || true)"
          args=()
          case "$interp" in
            *INTERP*) args+=(--set-interpreter "${stdenv.cc.bintools.dynamicLinker}") ;;
          esac
          if [ "$needs_rpath" = 1 ]; then
            args+=(--set-rpath "$rpath")
          fi
          if [ "''${#args[@]}" -gt 0 ]; then
            patchelf "''${args[@]}" "$f"
          fi
          ;;
      esac
    done < <(find $out -type f -print0)
  '';

  meta = {
    description = "Sota Connect — VPN client (Flutter GUI + kittend daemon, встроенный sing-box)";
    homepage = "https://sotavpn.net/";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "sotavpn";
  };
}
