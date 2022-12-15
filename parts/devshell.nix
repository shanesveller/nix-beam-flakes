{
  config,
  lib,
  flake-parts-lib,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
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
      _file = ./devshell.nix;

      options.beamWorkspace = mkSubmoduleOptions {
        devShell = {
          enable = mkEnableOption "beam-flakes devshells" // {default = true;};
          extraArgs = mkOption {
            type = types.attrsOf types.anything;
            default = {};
          };
          extraPackages = mkOption {
            type = types.listOf types.package;
            default = [];
            description = "Additional Nix packages to include in the generated devShell";
            example = "pkgs.watchexec";
          };
          iexShellHistory = mkEnableOption "IEx shell history" // {default = true;};
          packages = mkOption {
            internal = true;
            type = types.listOf types.package;
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
      beamWorkspace.devShell.packages =
        [
          cfg.packages.elixir
          cfg.packages.erlang
        ]
        ++ lib.optional cfg.devShell.languageServers.elixir cfg.packages.elixir-ls
        ++ lib.optional cfg.devShell.languageServers.erlang cfg.packages.erlang-ls;

      devShells = lib.mkIf (cfg.enable && cfg.devShell.enable) {
        default = pkgs.mkShell ({
            packages = cfg.devShell.packages ++ cfg.devShell.extraPackages;
            ERL_AFLAGS =
              if cfg.devShell.iexShellHistory
              then "-kernel shell_history enabled"
              else null;
          }
          // cfg.devShell.extraArgs);
      };
    };
  };
}
