# SDDM-темы (greeter)

Подборка качественных тем под эстетику Pixel / Material You + палитру Rosé Pine.
Активная тема настраивается в `nixos.nix` (опция
`services.displayManager.sddm.theme`).

## Активная тема: Nothing

**Самая красивая тема из найденных на данный момент — оставляем её.**

- Источник: <https://github.com/mahaveergurjar/sddm> (ветка `nothing`, Qt6).
- Nothing OS: монохром, точечный шрифт `Dot.ttf` (FontLoader), минимализм.
- Ветка **без** `metadata.desktop`/`theme.conf` — derivation генерирует их сама
  и подменяет заглушку-аватар `user.jpg` на `_assets/greeter-avatar.jpg`.
- Своё: фон dotted (из ветки), поле Username (не только `lastUser`).
- Своё: фон dotted (из ветки), поле Username (не только `lastUser`).
- Цвета настраиваются в `theme.conf`: `accent` (границы/кнопки/глиф сессии) и
  `text` (текст). Сейчас `accent=#907aa9` (Rosé Pine Iris, как в баре
  serpantinum), `text=white`. `Main.qml` пропатчен под `config.accent`/`config.text`
  с исходными фолбэками.
- Превью без выхода из сессии:
  ```sh
  sddm-greeter-qt6 --test-mode --theme /nix/store/<...>/share/sddm/themes/nothing
  ```

## Протестированные

- ~~**Noctalia** (<https://github.com/mahaveergurjar/sddm>, ветка `noctalia`) —
  Rosé Pine. Flake-инпут `noctalia-sddm` оставлен; чтобы вернуться, добавь в
  `let` и выставь `theme`:

  ```nix
  noctaliaTheme = pkgs.stdenvNoCC.mkDerivation {
    pname = "sddm-noctalia";
    version = "1.0";
    src = inputs.noctalia-sddm;
    dontConfigure = true;
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/share/sddm/themes/noctalia
      cp -r $src/. $out/share/sddm/themes/noctalia/
    '';
  };
  # theme = "${noctaliaTheme}/share/sddm/themes/noctalia";
  ```

- ~~**pixie-sddm** (<https://github.com/xCaptaiN09/pixie-sddm>) — Pixel/Material 3,
  автоцвет из обоев. Flake-инпут `pixie-sddm` оставлен в `nixos.nix`; чтобы
  вернуться, добавь в `let` и выставь `theme`:

  ```nix
  pixieTheme = inputs.pixie-sddm.packages.${pkgs.system}.pixie-sddm.override {
    background = ./_assets/greeter-bg.png;
    avatar = ./_assets/greeter-avatar.jpg;
    autoColor = true;
    backgroundColor = "#1A1C1E";
    textColor = "#E3E3DC";
    use24HourClock = true;
  };
  # theme = "${pixieTheme}/share/sddm/themes/pixie";
  ```

## Шортлист

| Тема | Ссылка | Лицензия | Особенности | Статус |
| --- | --- | --- | --- | --- |
| **Nothing** | <https://github.com/mahaveergurjar/sddm> (ветка `nothing`) | MIT | Монохром Nothing OS, точечный шрифт, Username-поле | **активна** — самая красивая на данный момент |
| ~~Noctalia~~ | <https://github.com/mahaveergurjar/sddm> (ветка `noctalia`) | MIT | Rosé Pine, адаптивный масштаб, power/session-контроли | протестирована |
| ~~pixie-sddm~~ | <https://github.com/xCaptaiN09/pixie-sddm> | MIT | Pixel/Material 3, автоцвет из обоев, flake `override` | протестирована |
| **qylock** | <https://github.com/Darkkal44/qylock> | GPL-3.0 | Коллекция SDDM + Quickshell-lock; `material-you`, `pixel-*`, NieR, Genshin, osu!; видео-фон; NixOS-модуль | — |
| **pixel** | <https://github.com/mahaveergurjar/sddm> (ветка `pixel`) | MIT | Android 16 / Pixel UI | — |
| **ronin** | <https://github.com/mahaveergurjar/sddm> (ветка `ronin`) | MIT | Самурайская тема | — |
| **SilentSDDM** | <https://github.com/uiriansan/SilentSDDM> | — | Строгий минимализм, очень настраиваемый, есть flake | — |
| **sddm-astronaut-theme** | <https://github.com/Keyitdev/sddm-astronaut-theme> | GPL-3.0 | Самый популярный, 10 тем + анимации; есть в nixpkgs (`sddm-astronaut`) | — |
| **sddm-sugar-dark** | <https://github.com/MarianArlt/sddm-sugar-dark> | GPL-3.0 | Классика, чистая вёрстка, легко перекрашивается | — |

Прочее: `sddm-astronaut` — в nixpkgs; `where-is-my-sddm-theme` (минимализм);
`catppuccin/sddm` (палитра Catppuccin).

## Почему «не те»

У большинства тем фон — зашитая чужая картинка и своя палитра. «Своими» ощущаются
те, что берут твои обои/аватар и подстраивают акцент: `pixie` (автоцвет из обоев) и
`noctalia` (Rosé Pine — совпадает с палитрой бара в `serpantinum settings.json`).

## Текущая/прошлые темы

- `material-you` — тема из коллекции [Darkkal44/qylock](https://github.com/Darkkal44/qylock),
  вендорится в пакет `serpantinum`; была исходной темой.
- `sddm-wired-theme` (Serial Experiments Lain) — собиралась из flake-инпута, удалена.

## Превью без выхода из сессии

```sh
sddm-greeter-qt6 --test-mode --theme /nix/store/<...>/share/sddm/themes/<theme>
```
