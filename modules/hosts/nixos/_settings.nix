{
  name = "nixos";
  arch = "x86_64-linux";
  # cpu читается через specialArgs-параметр (не из config — иначе infinite recursion)
  cpu = "amd";
  stateVersion = "24.11";
  homeStateVersion = "24.11";
  timeZone = "Asia/Yekaterinburg";

  user = {
    name = "litsummer";
    homeDir = "/home/litsummer";
  };

  domain = null;

  firewall = {
    allowedTCPPorts = [ ];
    allowedUDPPorts = [ ];
  };

  # --- SWAP (host-specific) ---
  # swap-файл отключён: гибернация (suspend-to-disk) не используется.
  # Подкачку обеспечивает zram (см. aspects/system.nix). Осиротевший
  # /var/lib/swapfile удаляется activation-хуком при swapSizeMb = 0.
  swapSizeMb = 0;

  # tlp/thermald выключены: serpantinum управляет питанием через power-profiles-daemon
  tlp = false;
}
