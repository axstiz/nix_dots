{
  flake-file.inputs.nixos-hardware.url = "github:nixos/nixos-hardware";
  flake-file.inputs.nixos-hardware.inputs.nixpkgs.follows = "nixpkgs";

  # Точечный бамп ядра (фаза D, 2026-11-08): только kernelPackages берётся
  # из свежего снапшота nixpkgs с ядром 6.18.60 (наш основной lock даёт
  # 6.18.53, на котором серия «безмолвных» DMCUB-локапов DCN2.1 у iGPU
  # Barcelo). Весь остальной мир остаётся на основном lock — полная
  # пересборка не требуется. Если фоллы прекратятся — отметить и
  # предложить: удерживать параллельный инпут или свернуть с основного.
  flake-file.inputs.nixpkgs-kernel.url = "github:nixos/nixpkgs/0bb2eedc20e4739f29e8045034f2828ad7054f8f";

  flake.modules.nixos.hardware-base =
    {
      inputs,
      pkgs,
      config,
      lib,
      host ? { },
      ...
    }:
    let
      h = config._module.args.host or { };
      # cpu читается через specialArgs-параметр: imports от config — infinite recursion
      cpu = host.cpu or "intel";
      # Управление питанием CPU через tlp/thermald (включено выборочно:
      # serpantinum по умолчанию управляет питанием через power-profiles-daemon)
      laptop = h.tlp or false;
    in
    {
      imports = [ inputs.nixos-hardware.nixosModules.${"common-cpu-" + cpu} ];

      # Тест LTS-ядра 6.12 (фаза E, 2026-11-08): 6.18.60 не спасает от
      # «безмолвных» DMCUB-локапов DCN2.1 у Barcelo даже с sg_display=0 +
      # dcdebugmask + gpu_recovery (упало через ~55 c после входа). Берём
      # зрелое LTS-ядро из основного pkgs — у него годы фиксов DCN2.1.
      # Если хэнги прекратятся — постараться убрать параметры из
      # _hardware.nix по одному и свернуть nixpkgs-kernel-инпут.
      boot.kernelPackages = pkgs.linuxPackages_6_12;

      services.tlp = lib.mkIf laptop {
        enable = true;
        settings = {
          PLATFORM_PROFILE_ON_AC = "performance";
          PLATFORM_PROFILE_ON_BAT = "balanced";

          CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
          CPU_ENERGY_PERF_POLICY_ON_BAT = "balanced";

          CPU_BOOST_ON_AC = 1;
          CPU_BOOST_ON_BAT = 0;

          CPU_MIN_PERF_ON_AC = 0;
          CPU_MAX_PERF_ON_AC = 100;

          CPU_MIN_PERF_ON_BAT = 0;
          CPU_MAX_PERF_ON_BAT = 40;

          START_CHARGE_THRESH_BAT0 = 0;
          STOP_CHARGE_THRESH_BAT0 = 1;
        };
      };

      services.thermald = lib.mkIf laptop {
        enable = true;
        package = pkgs.thermald;
      };
    };

  flake.modules.nixos.hardware-desktop =
    { pkgs, ... }:
    let
      # Bluetooth: дождаться появления hci0 на D-Bus (адаптер подгружается с задержкой)
      # и включить Pairable. С pairable=false BlueZ заявляет "No Bonding" в IO-capability
      # (видно в btmon: Authentication 0x00), ядро отдаёт New Link Key с Store hint=No —
      # ключи не сохраняются, все сопряжения получаются temporary (Bonded=false) и умирают
      # после disconnect/перезагрузки. У serpantinum этого нет — флаг Pairable=false
      # застрял в /var/lib/bluetooth/<adapter>/settings ещё до миграции.
      btPairableScript = pkgs.writeShellScript "bt-pairable-startup" ''
        for _ in $(seq 1 15); do
          if ${pkgs.systemd}/bin/busctl tree org.bluez 2>/dev/null | grep -q hci0; then
            ${pkgs.systemd}/bin/busctl set-property org.bluez /org/bluez/hci0 org.bluez.Adapter1 Pairable b true
            echo "bluetooth: Pairable enabled on hci0"
            exit 0
          fi
          sleep 2
        done
        echo "bluetooth: hci0 did not appear on D-Bus 30s, giving up"
        exit 0
      '';

      # Bluetooth: если адаптер внезапно пропал с шины (глюк RTL8852BU, "Unexpected
      # NULL btd_adv_monitor_manager..."), bluetoothd остаётся без единого hci0 и
      # виджет показывает пустоту; рестарт bluetoothd возвращает контроллер.
      btWatchdogScript = pkgs.writeShellScript "bt-watchdog" ''
        if ! ${pkgs.systemd}/bin/busctl tree org.bluez 2>/dev/null | grep -q hci0; then
          echo "bluetooth watchdog: hci0 missing, restarting bluetoothd"
          ${pkgs.systemd}/bin/systemctl restart bluetooth.service
        fi
      '';
    in
    {
      # --- ГРАФИКА ---
      hardware.graphics.enable = true;

      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
        settings = {
          General = {
            # fast connect: не ждать 30 сек, пока подключится следующее устройство
            FastConnectable = true;
          };
        };
      };

      # При каждом старте bluetoothd: включать Pairable (см. коммент у btPairableScript).
      systemd.services.bluetooth.serviceConfig.ExecStartPost = [ btPairableScript ];

      # Раз в 5 минут проверять, что адаптер на месте (см. коммент у btWatchdogScript).
      systemd.services.bluetooth-watchdog = {
        description = "Restart bluetoothd if adapter disappeared from the bus";
        serviceConfig = {
          Type = "oneshot";
          Restart = "no";
        };
        script = "${btWatchdogScript}";
      };
      systemd.timers.bluetooth-watchdog = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "1min";
          OnUnitActiveSec = "5min";
          Unit = "bluetooth-watchdog.service";
        };
      };

      services.pipewire = {
        enable = true;
        pulse.enable = true;
        alsa.enable = true;
      };

      services.libinput = {
        enable = true;
        touchpad.naturalScrolling = true;
      };
    };
}
