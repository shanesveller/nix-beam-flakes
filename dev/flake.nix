{
  description = "Contributor environment for Nix-based BEAM toolchain management";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs.follows = "nixpkgs";
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

      imports = [./checksums];

      perSystem = {
        config,
        lib,
        pkgs,
        system,
        ...
      }: {
        checks = {
          pre-commit-check = inputs.pre-commit.lib.${system}.run {
            src = ./..;
            hooks = {
              alejandra.enable = true;
              nix-linter.enable = pkgs.stdenv.isLinux;
              nixfmt.enable = false;
              nixpkgs-fmt.enable = false;
              prettier.enable = true;
              statix.enable = pkgs.stdenv.isLinux;
            };
            settings = {
              statix.ignore = [".direnv/*"];
            };
          };
        };

        devShells.default = pkgs.mkShell {
          buildInputs =
            [pkgs.just]
            ++ (with inputs.pre-commit.packages.${system};
              [alejandra pre-commit]
              ++ lib.optionals pkgs.stdenv.isLinux [nix-linter statix]);
          inherit (config.checks.pre-commit-check) shellHook;
        };

        packages.gcroot =
          pkgs.linkFarmFromDrvs "beam-overlay-dev"
          [config.devShells.default.inputDerivation];
      };
    };
}
