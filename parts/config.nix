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
    mkOption
    types
    ;
  inherit
    (flake-parts-lib)
    mkPerSystemOption
    ;
in {
  options = {
    perSystem = mkPerSystemOption ({pkgs, ...}: {
      _file = ./config.nix;

      options = {
        beamWorkspace = {
          enable = mkEnableOption "beam-flakes";
          packages = {
            elixir = mkOption {
              type = types.nullOr types.package;
            };
            elixir_ls = mkOption {
              type = types.nullOr types.package;
            };
            erlang = mkOption {
              type = types.nullOr types.package;
            };
            erlang-ls = mkOption {
              type = types.nullOr types.package;
            };
          };

          pkgs = mkOption {
            type = types.uniq (types.lazyAttrsOf (types.raw or types.unspecified));
            default = pkgs;
          };

          pkgSet = mkOption {
            type = types.uniq (types.lazyAttrsOf types.package);
          };

          versions = {
            elixir = mkOption {
              type = types.nullOr (types.strMatching "^([0-9]+)\.([0-9]+)\.([0-9]+)(-otp-[0-9]+)?$");
            };
            erlang = mkOption {
              type = types.nullOr (types.strMatching "^([0-9]+)\.([0-9]+)(\.([0-9]+))?(\.([0-9+]))?$");
            };
            fromToolVersions = mkOption {
              type = types.nullOr types.path;
            };
          };
        };
      };
    });
  };

  config = {
    perSystem = {config, ...}: let
      cfg = config.beamWorkspace;
    in {
      beamWorkspace.packages = mkIf (cfg.versions.elixir != null && cfg.versions.erlang != null) (let
        pkgset = beam-flakes-lib.mkPackageSet {
          elixirVersion = beam-flakes-lib.normalizeElixir cfg.versions.elixir;
          erlangVersion = cfg.versions.erlang;
          elixirLanguageServer = true;
          erlangLanguageServer = true;
          inherit (cfg) pkgs;
        };
      in {
        inherit (pkgset) elixir erlang elixir_ls erlang-ls;
      });
    };
  };
}
