{
  lib,
  modulesPath,
  pkgs,
  ...
}:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # Эксперименты против «зелёного монитора + чёрного ноута + полной
  # неотвеченности» (2026-11, ~17 зависаний; ядро/система при этом
  # живы — безмолвный DCN/DMCUB-локап на переходах состояния дисплея).
  # Фаза F (2026-11-09, вариант B — пакетный удар): лог последнего
  # падения обрывается на флапе «Allow idle optimizations (MALL)» в
  # amdgpu_dm_crtc_vblank_control_worker, поэтому глушим сразу все
  # топ-подозреваемые энергосберегающие оптимизации дисплея:
  #   0x2   DC_DISABLE_STUTTER  — self-refresh VRAM при статичной картинке
  #   0x10  DC_DISABLE_PSR      — Panel Self Refresh панели ноутбука
  #   0x800 DC_DISABLE_IPS      — Idle Power States (включая MALL в простое)
  # Итого 0x812. Цена — только батарея/тепло; обратимо, см. enum
  # DC_DEBUG_MASK в drivers/gpu/drm/amd/include/amd_shared.h.
  # gpu_recovery=1 — драйвер пробует автоматическое восстановление после
  # GPU-hang (MODE2) вместо вечного фриза.
  # drm.debug=4 — ВРЕМЕННО (kms-логи для улик о следующем падении);
  # убрать вместе с gpu_recovery после стабилизации.
  # Если хэнги прекратятся — откручивать биты по одному (сначала
  # stutter, потом IPS), подтверждая минимальный кит.
  # ВНИМАНИЕ: «amdgpu.dpm=0» НЕ добавлять — на iGPU Barcelo (DCN2.1)
  # полное отключение DPM ломает ранний бут (проверено 2026-11-06:
  # система не стартовала вовсе).
  boot.kernelParams = [
    "amdgpu.dcdebugmask=0x812"
    "amdgpu.gpu_recovery=1"
    "drm.debug=4"
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/3bd9c9c5-9e4b-4fc7-b798-b660bb478853";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/A800-4A63";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [ ];

  # Фаза T (2026-11-10): мягкий лимит процессора против thermal trip
  # (полное hard-off «в никуда» при резком burst-boost до 4.39 ГГц на
  # Barcelo, Tj max 105 °C; простой при этом Watson уже 73–77 °C).
  # 1) boost=0 — вырубает turbo-boost вообще; 2) потолок 3.2 ГГц на
  # каждое ядро (против 4.39) — CPU остаётся быстрее базовых 2.3 ГГц,
  # но peak temp резко падает. Не трогает TLP/power-profiles-daemon
  # (EPP остаётся у Serpantinum), ядро и boot-параметры не меняются —
  # риск «не стартует» нулевой, юнит просто пишет цифрочки в sysfs
  # после графа multi-user.
  # ОТКАТ: удалить блок (или закомментировать) + nixos-rebuild switch;
  # на лету без пересборки: echo 1 > /sys/devices/system/cpu/cpufreq/boost
  # и echo 4388000 > /sys/.../cpu*/cpufreq/scaling_max_freq.
  systemd.services.cpu-cool = {
    description = "cpu-cool: boost off + freq cap 3.2 GHz (thermal-эксперимент)";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "cpu-cool" ''
        echo 0 > /sys/devices/system/cpu/cpufreq/boost
        for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq; do
          echo 3200000 > "$f"
        done
      '';
    };
  };

  networking.useDHCP = lib.mkDefault true;
}
