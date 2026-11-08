# SDDM-темы (greeter)

Все протестированные темы лежат в attrset `themes` в `nixos.nix`; активная
выбирается одной строкой `activeSddmTheme = "<имя>"`. Каталог темы в сторе
совпадает с именем ключа. Так протестированные темы не теряются (deadnix не
удаляет их).

## Лучшая тема: Pixel — ИМБА

- Источник: <https://github.com/mahaveergurjar/sddm> (ветка `pixel`, Qt6).
- Android 16 / Pixel UI, композиция «ii-lock»: analog-бейдж с датой, пилюли
  user/session, пароль точками (`PixelDots`), экранная клавиатура, power-кнопки.
- Перекрашена в палитру системы: amber-цвета заменены на значения из
  `systemPalette` в `nixos.nix` (serpantinum `CustomTheme` / Catppuccin Mocha —
  accent-mauve `#cba6f7`, surface `#0b0b0d`/`#2b2b33`, text `#eeeff2`).
- Фон — активные обои (`catpuccin.jpg` из `serpantinum-wallpapers`, лежит в
  `_assets/greeter-wallpaper.jpg`); при сборке конвертируется в PNG
  (`imagemagick`). Это снимок на момент сборки — при смене обоев нужен rebuild.
- Ветка отдаёт `metadata.desktop` в KDE-формате без `MainScript` — derivation
  дописывает корректный `metadata.desktop` (как для Nothing).

## Catppuccin — протестирована (между норм и мимо)

- Источник: <https://github.com/catppuccin/sddm> — **уже в nixpkgs** как
  `pkgs.catppuccin-sddm` (инпут не нужен).
- Готовые flavor/accent через `override`; взял `mocha` + `mauve` (совпадает с
  палитрой системы), шрифт `JetBrainsMono Nerd Font`, фон — свои обои,
  `loginBackground = true`.
- Каталог в сторе — `catppuccin-<flavor>-<accent>`; нормализован обёрткой
  `runCommand` до `catppuccin`, чтобы работал общий `themes.${name}`.
- В `metadata.desktop` у апстрима `Type=sddm-theme` (рабочее значение для SDDM),
  менять не пришлось.

## Ronin — протестирована (норм, не вау)

- Источник: <https://github.com/mahaveergurjar/sddm> (ветка `ronin`, Qt6).
- Самурайская Demon Slayer, hyprlock-стиль: 4 frosted-glass карточки (логин,
  часы, профиль, система), ComboBox-селекторы user/session, power-пилюли.
- Доработки derivation: импорт `QtGraphicalEffects 1.15` → `Qt5Compat.GraphicalEffects`
  (Qt6); абсолютные пути автора к обоям/аватару заменены на свои
  (`_assets/greeter-wallpaper.jpg`, `_assets/greeter-avatar.jpg`);
  «Arch Linux» → «NixOS», убран хардкод имени; цвета — в палитру системы
  (ren: `#BA3D3D`→accent, `#CCA47C`→pink, `#F0E6DC`→text, `#B9AFA5`→subtext0);
  `metadata.desktop` дописан (`Type=greeter`, `Theme-API=2.0`, `QtVersion=6`).

## Astronaut — шикарно, но pixel чуть лучше

- Источник: <https://github.com/Keyitdev/sddm-astronaut-theme>, **в nixpkgs**
  (`sddm-astronaut`, Qt6). Самый популярный, 10 встроенных тем (astronaut,
  black_hole, cyberpunk, hyprland_kath, jake_the_dog, japanese_aesthetic,
  pixel_sakura, pixel_sakura_static, post-apocalyptic_hacker, purple_leaves).
- Взят встроенный профиль `astronaut`. Каталог `sddm-astronaut-theme`
  нормализован до `astronaut`; конфиг — `Themes/astronaut.conf` (в metadata
  `ConfigFile=Themes/astronaut.conf`).
- Конфиг перекрашен под `systemPalette` (text `#eeeff2`, accent-mauve
  `#cba6f7` на кнопке логина, surface `#1d1d22` в полях, pink `#f5c2e7` на
  hover, red для warning) и шрифт `JetBrainsMono Nerd Font`.
- Фон — активные обои (`_assets/greeter-wallpaper.jpg` → `Backgrounds/astronaut.png`).
- Блок логина прижат влево: `FormPosition="left"`.
- Кнопки питания: `BypassSystemButtonsChecks="true"`, чтобы не зависеть от
  `sddm.canPowerOff/canReboot/...` (в `--test-mode` они все `false` и кнопки
  скрываются).
- Нужен `pkgs.qt6Packages.qtvirtualkeyboard` в `extraPackages` (модуль
  `QtQuick.VirtualKeyboard`), иначе экранная клавиатура не грузится.
- `themeConfig` из пакета не используем: он пишет `Themes/<t>.conf.user`, а
  metadata ссылается на `.conf` — поэтому конфиг правим sed'ом в обёртке.

## Курсор greeter (Wayland/weston)

- В Wayland-режиме курсор рисует композитор (`weston --shell=kiosk`), а не SDDM.
- `libwayland-cursor` собирается с зашитым `ICONDIR`, указывающим в
  несуществующий `share`-output (`.../wayland-1.26.0/share/icons`) — каталога нет,
  поэтому курсор не находился, и кликнуть по кнопкам питания было нельзя.
- Фикс в `nixos.nix`: derivation `sddmCursors` (symlink `default` и
  `BreezeX-RosePine-Linux` → `pkgs.rose-pine-cursor`) + `XCURSOR_PATH` в
  `services.displayManager.generic.environment` (пробрасывается в
  `display-manager.service` → `sddm` → `weston`) + `Theme.CursorTheme`/`CursorSize`.
- Короткая вспышка текста UWSM/Hyprland на VT2 при входе — штатное поведение
  смены VT1→VT2, не ошибка.

## Переключение темы

```nix
# modules/aspects/wm/nixos.nix, в let:
activeSddmTheme = "pixel";  # pixie | noctalia | nothing | pixel | ronin | catppuccin | astronaut
```

## Шортлист

| Тема | Ссылка | Лицензия | Особенности | Статус |
| --- | --- | --- | --- | --- |
| **sddm-astronaut** | <https://github.com/Keyitdev/sddm-astronaut-theme> | GPL-3.0 | 10 тем + анимации; **в nixpkgs** (`sddm-astronaut`) | протестирована (шикарно, но pixel чуть лучше) |
| ~~pixie-sddm~~ | <https://github.com/xCaptaiN09/pixie-sddm> | MIT | Pixel/Material 3, автоцвет из обоев, flake `override` | протестирована |
| ~~Noctalia~~ | <https://github.com/mahaveergurjar/sddm> (ветка `noctalia`) | MIT | Rosé Pine, адаптивный масштаб, power/session-контроли | протестирована |
| **Nothing** | <https://github.com/mahaveergurjar/sddm> (ветка `nothing`) | MIT | Монохром Nothing OS, точечный шрифт, Username-поле | протестирована (акцент #907aa9) |
| **Pixel** | <https://github.com/mahaveergurjar/sddm> (ветка `pixel`) | MIT | Android 16 / Pixel UI, analog-бейдж, virtual keyboard | **ИМБА — лучшая** (системная палитра + свои обои) |
| **ronin** | <https://github.com/mahaveergurjar/sddm> (ветка `ronin`) | MIT | Demon Slayer / hyprlock-стиль, frosted-glass карточки, Qt5-импорт (пофикшен) | протестирована (норм, не вау) |
| **catppuccin** | <https://github.com/catppuccin/sddm> | MIT | Mocha+mauve под палитру системы; **в nixpkgs** (`catppuccin-sddm`) | протестирована (между норм и мимо) |
| **qylock** | <https://github.com/Darkkal44/qylock> | GPL-3.0 | Коллекция SDDM + Quickshell-lock; `material-you`, `pixel-*`, NieR, Genshin, osu!; видео-фон; NixOS-модуль | — |
| **SilentSDDM** | <https://github.com/uiriansan/SilentSDDM> | — | Строгий минимализм, очень настраиваемый, есть flake | — |
| **sddm-sugar-dark** | <https://github.com/MarianArlt/sddm-sugar-dark> | GPL-3.0 | Классика, чистая вёрстка, легко перекрашивается | — |

Прочее: `where-is-my-sddm-theme` (минимализм).

## Почему «не те»

У большинства тем фон — зашитая чужая картинка и своя палитра. «Своими» ощущаются
те, что берут твои обои/аватар и подстраивают акцент: `pixie` (автоцвет из обоев) и
`nothing` (монохром + акцент Rosé Pine Iris `#907aa9`, совпадает с баром
serpantinum).

## Текущая/прошлые темы

- `material-you` — тема из коллекции [Darkkal44/qylock](https://github.com/Darkkal44/qylock),
  вендорится в пакет `serpantinum`; была исходной темой.
- `sddm-wired-theme` (Serial Experiments Lain) — собиралась из flake-инпута, удалена.

## Превью без выхода из сессии

```sh
sddm-greeter-qt6 --test-mode --theme /nix/store/<...>/share/sddm/themes/<theme>
```
