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
    fullname = "Матвей Вахрушев";
    email = "litsummer@localhost";
    homeDir = "/home/litsummer";
  };

  domain = null;

  firewall = {
    allowedTCPPorts = [ ];
    allowedUDPPorts = [ ];
  };

  # --- SWAP + ГИБЕРНАЦИЯ (host-specific) ---
  # Файл подкачки на корне (ext4): страховка от OOM + база для гибернации,
  # создаётся автоматически при активации. Образ ОЗУ ищется ядром по
  # resume=<раздел> resume_offset=<физблок первого экстента файла>.
  # Offset посчитан один раз: sudo filefrag -v /var/lib/swapfile | grep -m1 '^ 0:' → 17915904.
  # ВАЖНО: если вручную удалить/пересоздать swap-файл — offset пересчитать и обновить тут.
  swapSizeMb = 16 * 1024;
  resumeDevice = "/dev/nvme0n1p5";
  resumeOffset = "17915904";

  # tlp/thermald выключены: serpantinum управляет питанием через power-profiles-daemon
  tlp = false;
}
