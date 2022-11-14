{
  description = "My Phoenix application";

  inputs = {
    beam-flakes.url = "github:shanesveller/nix-beam-flakes";
    beam-flakes.inputs.flake-parts.follows = "flake-parts";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = {
    self,
    beam-flakes,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit self;} {
      imports = [beam-flakes.flakeModule];

      systems = ["aarch64-darwin" "x86_64-darwin" "x86_64-linux"];

      perSystem = {pkgs, ...}: let
        beamPkgs = beam-flakes.lib.packageSetFromToolVersions pkgs ./.tool-versions {
          elixirLanguageServer = true;
        };
      in {
        devShells.default = pkgs.mkShell {
          packages = with beamPkgs; [elixir erlang elixir_ls];
        };

        packages = {
          inherit (beamPkgs) erlang elixir elixir_ls;
        };
      };
    };
}
