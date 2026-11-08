{ lib, modulesPath, ... }: {
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
  # неотвеченности» (2026-11, 3 зависания за вечер; ядро/система при этом
  # живы — безмолвный DCN/DMCUB-локап на переходах состояния дисплея).
  # dcdebugmask=0x10 — выключает PSR (Panel Self Refresh) у iGPU Barcelo:
  # главный подозреваемый в DMCUB-фейлах при resume/простое.
  # gpu_recovery=1 — драйвер пробует автоматическое восстановление после
  # GPU-hang (MODE2) вместо вечного фриза.
  # Если хэнги прекратятся — можно убрать по одному (сначала gpu_recovery).
  boot.kernelParams = [
    "amdgpu.dcdebugmask=0x10"
    "amdgpu.gpu_recovery=1"
    # ВНИМАНИЕ: «amdgpu.dpm=0» НЕ добавлять — на iGPU Barcelo (DCN2.1)
    # полное отключение DPM ломает ранний бут (проверено 2026-11-06:
    # система не стартовала вовсе). Точечная подача SMU через
    # ppfeaturemask не проверена; следующий кандидат — kernel-bump.
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

  networking.useDHCP = lib.mkDefault true;
}
