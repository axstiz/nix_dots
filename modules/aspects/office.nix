{
  # OnlyOffice: Documents (Word), Spreadsheets (Excel), Presentations (PowerPoint).
  # unfree-пакет, объявлен в local.unfreePackages (aspects/system.nix).
  flake.modules.homeManager.office = { pkgs, ... }: {
    home.packages = with pkgs; [ onlyoffice-desktopeditors ];
  };
}
