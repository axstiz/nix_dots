{
  flake.modules.nixos.networking =
    { pkgs, config, ... }:
    let
      h = config._module.args.host or { };
    in
    {
      networking = {
        hostName = h.name or "nixos";
        domain = h.domain or null;
        nftables.enable = true;
        firewall = {
          enable = true;
          allowPing = false;
          allowedTCPPorts = h.firewall.allowedTCPPorts or [ ];
          allowedUDPPorts = h.firewall.allowedUDPPorts or [ ];
        };
        networkmanager = {
          enable = true;
          package = pkgs.networkmanager;
        };
      };
    };
}
