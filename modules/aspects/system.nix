{
  flake.modules.nixos.system =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      h = config._module.args.host or { };
      swap = h.swapSizeMb or 16384;
    in
    {
      system.stateVersion = h.stateVersion or "24.11";

      # --- ЗАГРУЗКА ---
      # Лимит старых ядер в меню загрузки: /boot всего 1 ГБ, по умолчанию
      # накапливается ~100 записей и со временем ESP забивается.
      boot.loader.systemd-boot.enable = true;
      boot.loader.systemd-boot.configurationLimit = 10;
      boot.loader.efi.canTouchEfiVariables = true;

      # --- ГИБЕРНАЦИЯ (suspend-to-disk) ---
      # Образ ОЗУ пишется в swap-файл; ядро при загрузке ищет его по
      # resume=<раздел> resume_offset=<физблок первого экстента файла>.
      # Значения читаются из host-настроек (_settings.nix хоста).
      # ВАЖНО: если вручную удалить/пересоздать swap-файл —
      # resume_offset пересчитать (sudo filefrag -v /var/lib/swapfile) и обновить.
      boot.resumeDevice = lib.mkIf (h.resumeDevice or null != null) h.resumeDevice;
      boot.kernelParams = lib.mkIf (h.resumeOffset or null != null) [ "resume_offset=${h.resumeOffset}" ];

      # --- SWAP ---
      # Сжатая подкачка в RAM: дёшево и без износа SSD.
      zramSwap.enable = true;
      # Файл подкачки на корне (ext4): страховка от OOM + база для гибернации.
      # Файл создаётся автоматически при активации.
      swapDevices = lib.mkIf (swap > 0) [
        {
          device = "/var/lib/swapfile";
          size = swap;
        }
      ];

      # --- КНОПКА ПИТАНИЯ ---
      # Короткое нажатие: logind не перехватывает (по умолчанию он сразу выключает
      # систему, не доходя до Hyprland) — событие XF86PowerOff попадает в бинд
      # serpantinum lock из home.nix. Удержание ~5 сек: logind сам выключает систему.
      services.logind.settings.Login = {
        HandlePowerKey = "ignore";
        HandlePowerKeyLongPress = "poweroff";
      };

      # --- SSD: еженедельный Trim (корень на ext4/NVMe) ---
      services.fstrim.enable = true;

      # --- fwupd: обновления прошивок устройств (BIOS/SSD/контроллеры) ---
      services.fwupd.enable = true;

      time.timeZone = h.timeZone or "Asia/Yekaterinburg";
      i18n.defaultLocale = "ru_RU.UTF-8";
      i18n.extraLocaleSettings = {
        LC_ADDRESS = "ru_RU.UTF-8";
        LC_IDENTIFICATION = "ru_RU.UTF-8";
        LC_MEASUREMENT = "ru_RU.UTF-8";
        LC_MONETARY = "ru_RU.UTF-8";
        LC_NAME = "ru_RU.UTF-8";
        LC_NUMERIC = "ru_RU.UTF-8";
        LC_PAPER = "ru_RU.UTF-8";
        LC_TELEPHONE = "ru_RU.UTF-8";
        LC_TIME = "ru_RU.UTF-8";
      };

      # --- ШРИФТЫ ---
      fonts.packages = with pkgs; [
        material-symbols
        noto-fonts-color-emoji
        rubik
        nerd-fonts.jetbrains-mono
        nerd-fonts.caskaydia-cove
      ];

      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      local.unfreePackages = [
        "vscode"
        "obsidian"
        "yandex-music"
        "unrar"
        "chromium"
        "onlyoffice-desktopeditors"
      ];
    };
}
