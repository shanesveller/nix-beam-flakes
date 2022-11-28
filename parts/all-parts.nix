{...}: {
  imports = [
    ./lib.nix
    ./config.nix
    ./devshell.nix
    ./language-server.nix
    ./packages.nix
  ];
}
