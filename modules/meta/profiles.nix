{ inputs, ... }:
let
  n = inputs.self.modules.nixos;
  hm = inputs.self.modules.homeManager;
in
{
  flake.lib.profiles = {
    nixos = rec {
      base = [
        n.system
        n.hardware-base
        n.networking
        n.unfree
        n.certificates
      ];
      desktop = base ++ [
        n.hardware-desktop
        n.audio
        n.wm
        n.services
        n.apps
        n.browsers
        n.media
        n.database
        n.cli
        n.toys
        n.develop
        n.zed
        n.tg-ws-proxy
        n.vpn
      ];
    };
    home = rec {
      minimal = [
        hm.develop
        hm.direnv
        hm.terminal
        hm.opencode
      ];
      desktop = minimal ++ [
        hm.serpantinum
        hm.tg-ws-proxy
        hm.wm
        hm.zed
        hm.office
      ];
    };
  };
}
