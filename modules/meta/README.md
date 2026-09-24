# Мета модули

Модули для надстройки **флейка/конфигурации**.

- `flake-file.nix` - декларация flake-инпутов; после правок - `nix run .#write-flake`.
- `profiles.nix`  профили: готовые композиции аспектов для хостов.
- `unfree.nix` - опция `local.unfreePackages` + единый `allowUnfreePredicate`
  (аспекты разрешают unfree-пакеты только через неё, см. AGENTS.md).
- `lib/` - механизмы сборки конфигураций:
  - `flake-modules.nix` - опция `flake.modules.<class>.<aspect>` (основа дендритного паттерна);
  - `systems.nix` - обёртка `mkNixosSystem` (пробрасывает `host` и `inputs` в модули);
  - `facter.nix` - `facter`-функция для хостов + приложение `nix run .#facter`.
- `tools/` - инструменты разработки репозитория (на саму систему не влияют):
  - `devshell.nix` - dev-окружение;
  - `pre-commit.nix` - git-хуки;
  - `treefmt.nix` - форматирование (`nix fmt`).
