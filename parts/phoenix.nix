{
  config,
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
      _file = ./phoenix.nix;

      options.beamWorkspace.devShell = mkSubmoduleOptions {
        phoenix = mkEnableOption "phoenix framework";
      };
    });
  };

  config = {
    perSystem = {pkgs, ...}: {
      beamWorkspace.devShell.packages = mkMerge [
        (mkIf pkgs.stdenv.isDarwin (with pkgs.darwin.apple_sdk.frameworks; [CoreServices]))
        (mkIf pkgs.stdenv.isLinux [pkgs.inotify-tools])
      ];
    };
  };
}
