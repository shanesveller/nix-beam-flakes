{
  lib,
  flake-parts-lib,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkMerge
    mkIf
    ;
  inherit
    (flake-parts-lib)
    mkPerSystemOption
    mkSubmoduleOptions
    ;
in {
  options = {
    perSystem = mkPerSystemOption (_: {
      _file = ./language-server.nix;

      options.beamWorkspace.devShell = mkSubmoduleOptions {
        languageServers = {
          elixir = mkEnableOption "elixir-ls";
          erlang = mkEnableOption "erlang-ls";
        };
      };
    });
  };

  config = {
    perSystem = {config, ...}: let
      cfg = config.beamWorkspace;
    in {
      beamWorkspace.devShell.packages = mkMerge [
        (mkIf cfg.devShell.languageServers.erlang [
          cfg.packages.erlang-ls
        ])
        (mkIf cfg.devShell.languageServers.elixir [
          cfg.packages.elixir-ls
        ])
      ];
    };
  };
}
