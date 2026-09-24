let
  userName = "litsummer";
in
{
  flake.modules.nixos.litsummer = { ... }: {
    users.users.${userName} = {
      isNormalUser = true;
      description = "Матвей Вахрушев";
      extraGroups = [
        "networkmanager"
        "wheel"
        "video"
        "docker"
      ];
    };
  };

  flake.modules.homeManager.litsummer =
    { config, lib, ... }:
    let
      h = config._module.args.host or { };
    in
    {
      home.username = lib.mkDefault userName;
      home.homeDirectory = lib.mkDefault "/home/${userName}";
      home.stateVersion = lib.mkDefault (h.homeStateVersion or "24.11");
    };
}
