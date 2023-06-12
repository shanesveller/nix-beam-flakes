{
  description = "My Elixir application";

  inputs = {
    beam-flakes.url = "path:./../..";
    beam-flakes.inputs.flake-parts.follows = "flake-parts";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = inputs @ {
    beam-flakes,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [beam-flakes.flakeModule];

      systems = ["aarch64-darwin" "x86_64-darwin" "x86_64-linux"];

      perSystem = {
        pkgs,
        system,
        ...
      }: {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [beam-flakes.overlays.elixir_prerelease];
        };
        beamWorkspace = {
          enable = true;
          devShell.languageServers.elixir = true;
          devShell.languageServers.erlang = false;
          flakePackages = true;
          versions = {
            elixir = "1.15.0-rc.1";
            erlang = "26.0";
          };
          # versions.fromToolVersions = ./.tool-versions;
        };

        packages.elixir = builtins.trace (builtins.attrNames pkgs.beam.interpreters) pkgs.beamPackages.elixir_1_15;
      };
    };
}
