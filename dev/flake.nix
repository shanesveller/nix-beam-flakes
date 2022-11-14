{
  description = "Contributor environment for Nix-based BEAM toolchain management";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    pre-commit = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit self;} {
      systems = ["aarch64-darwin" "x86_64-darwin" "x86_64-linux"];

      imports = [./checksums inputs.pre-commit.flakeModule];

      perSystem = {
        config,
        lib,
        pkgs,
        system,
        ...
      }: {
        devShells.default = pkgs.mkShell {
          buildInputs =
            [pkgs.just]
            ++ (with inputs.pre-commit.packages.${system};
              [alejandra pre-commit]
              ++ lib.optionals pkgs.stdenv.isLinux [statix]);
          shellHook = config.pre-commit.installationScript;
        };

        packages.gcroot =
          pkgs.linkFarmFromDrvs "beam-overlay-dev"
          [config.devShells.default.inputDerivation];

        pre-commit = {
          settings = {
            hooks = {
              alejandra.enable = true;
              prettier.enable = true;
              statix.enable = pkgs.stdenv.isLinux;
            };
            rootSrc = lib.mkForce ./..;
            settings = {
              statix.ignore = [".direnv/*"];
            };
          };
        };
      };
    };
}
