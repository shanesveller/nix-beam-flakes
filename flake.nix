{
  description = "Nix-based BEAM toolchain management";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit self;} {
      imports = [./parts/all-parts.nix];
      systems = ["aarch64-darwin" "x86_64-darwin" "x86_64-linux"];
    };
}
