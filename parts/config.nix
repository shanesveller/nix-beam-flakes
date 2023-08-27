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
              internal = true;
              type = types.nullOr types.package;
            };
            elixir-ls = mkOption {
              internal = true;
              type = types.nullOr types.package;
            };
            erlang = mkOption {
              internal = true;
              type = types.nullOr types.package;
            };
            erlang-ls = mkOption {
              internal = true;
              type = types.nullOr types.package;
            };
          };

          pkgSet = mkOption {
            internal = true;
            type = types.uniq (types.lazyAttrsOf types.package);
          };

          versions = {
            elixir = mkOption {
              description = ''
                Textual version of Elixir to use. For compatibility reasons, an
                optional suffix such as "-otp-24" may be present, but will have no effect.
              '';
              example = "1.14.2";
              type = types.nullOr (types.strMatching "^([0-9]+)\.([0-9]+)\.([0-9]+)(-otp-[0-9]+)?$");
            };
            erlang = mkOption {
              description = "Textual version of Erlang/OTP to use";
              example = "25.2";
              type = types.nullOr (types.strMatching "^([0-9]+)\.([0-9]+)(\.([0-9]+))?(\.([0-9+]))?$");
            };
            fromToolVersions = mkOption {
              description = "Read versions.{language} from an ASDF-compatible .tools-version file at the indicated path";
              example = "./.tool-versions";
              type = types.nullOr types.path;
            };
          };
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
      beamWorkspace.packages = mkIf (cfg.versions.elixir != null && cfg.versions.erlang != null) (let
        pkgset = beam-flakes-lib.mkPackageSet {
          inherit pkgs;
          elixirVersion = beam-flakes-lib.normalizeElixir cfg.versions.elixir;
          erlangVersion = cfg.versions.erlang;
          elixirLanguageServer = true;
          erlangLanguageServer = true;
        };
      in {
        inherit (pkgset) elixir erlang elixir-ls erlang-ls;
      });
    };
  };
}
