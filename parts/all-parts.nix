{...}: {
  imports = [
    ./lib.nix
    ./tool-versions.nix
    ./config.nix
    ./devshell.nix
    ./language-server.nix
    ./packages.nix
  ];
}
