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
        n.wm
        n.services
        n.im
        n.browsers
        n.viewers
        n.games
        n.tui
        n.dev
        n.zed
        n.tg-ws-proxy
        n.throne
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
      ];
    };
  };
}
