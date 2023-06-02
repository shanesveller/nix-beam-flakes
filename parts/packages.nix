{
  lib,
  beam-flakes-lib,
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
    perSystem = mkPerSystemOption ({pkgs, ...}: {
      _file = ./config.nix;

      options = {
        beamWorkspace = mkSubmoduleOptions {
          flakePackages = mkEnableOption "packages outputs";
        };
      };
    });
  };

  config = {
    perSystem = {
      config,
      pkgs,
      ...
    }: let
      cfg = config.beamWorkspace;
    in {
      packages = mkIf cfg.flakePackages (mkMerge [
        {
          inherit (cfg.packages) elixir erlang;

          elixir_1_15 = pkgs.beam.beamLib.callElixir ./elixir_1_15.nix {
            inherit (cfg.packages) erlang;
            debugInfo = true;
          };
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
