{
  lib,
  beam-flakes-lib,
  flake-parts-lib,
  ...
}: let
  inherit
    (lib)
    mkIf
    mkOption
    types
    ;
  inherit
    (flake-parts-lib)
    mkPerSystemOption
    mkSubmoduleOptions
    ;
in {
  options = {
    perSystem = mkPerSystemOption (_: {
      _file = ./tool-versions.nix;

      options.beamWorkspace.versions = mkSubmoduleOptions {
        fromToolVersions = mkOption {
          type = types.nullOr types.path;
          default = null;
        };
      };
    });
  };

  config = {
    perSystem = {config, ...}: let
      cfg = config.beamWorkspace;
      toolVersions =
        if (cfg.versions.fromToolVersions != null)
        then (beam-flakes-lib.parseToolVersions cfg.versions.fromToolVersions)
        else {};
    in {
      beamWorkspace.versions.elixir = mkIf (toolVersions != {}) (beam-flakes-lib.normalizeElixir toolVersions.elixir);
      beamWorkspace.versions.erlang = mkIf (toolVersions != {}) toolVersions.erlang;
    };
  };
}
