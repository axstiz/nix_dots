{
  # OnlyOffice: Documents (Word), Spreadsheets (Excel), Presentations (PowerPoint).
  # unfree-пакет, объявлен в local.unfreePackages (aspects/system.nix).
  #
  # ВНИМАНИЕ при будущем обновлении nixpkgs до снапшота 26.11+:
  # там onlyoffice потянет gtk+-2 (broken, удаляется в 27.05) и сломает
  # evaluation — тогда вернуть overlay-pin на inputs.nixpkgs-stable (26.05,
  # onlyoffice 9.1.0) по образцу throne в aspects/vpn/nixos.nix. Также тогда
  # пригодятся записи из aspects/system.nix (unfree firefox-esr-140-bin-
  # unwrapped и permittedInsecurePackages).
  flake.modules.homeManager.office = { pkgs, ... }: {
    home.packages = with pkgs; [ onlyoffice-desktopeditors ];
  };
}
