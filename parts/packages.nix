{
  lib,
  flake-parts-lib,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    mkMerge
    ;
  inherit
    (flake-parts-lib)
    mkPerSystemOption
    mkSubmoduleOptions
    ;
in {
  options = {
    perSystem = mkPerSystemOption (_: {
      _file = ./config.nix;

      options = {
        beamWorkspace = mkSubmoduleOptions {
          flakePackages = mkEnableOption "packages outputs";
        };
      };
    });
  };

  config = {
    perSystem = {config, ...}: let
      cfg = config.beamWorkspace;
    in {
      packages = mkIf cfg.flakePackages (mkMerge [
        {
          inherit (cfg.packages) elixir erlang;
        }
        (mkIf cfg.devShell.languageServers.erlang {
          inherit (cfg.packages) erlang-ls;
        })
        (mkIf cfg.devShell.languageServers.elixir {
          inherit (cfg.packages) elixir-ls;
        })
      ]);
    };
  };
}
