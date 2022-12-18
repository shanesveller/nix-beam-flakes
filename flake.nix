{
  description = "Nix-based BEAM toolchain management";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [./parts/all-parts.nix ./local-parts];
      systems = ["aarch64-darwin" "x86_64-darwin" "x86_64-linux"];

      flake = {
        flakeModule = ./parts/all-parts.nix;

        perSystem = {pkgs, ...}: {
          formatter = pkgs.alejandra;
        };

        templates = {
          default = {
            path = ./templates/default;
            description = "An environment suitable for developing Elixir applications";
          };

          phoenix = {
            path = ./templates/phoenix;
            description = "An environment suitable for developing Phoenix 1.7 applications";
          };
        };
      };
    };
}
