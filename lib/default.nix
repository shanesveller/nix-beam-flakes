{lib}: let
  inherit (lib.trivial) importJSON;
  inherit (findBasePackage) elixirBasePackage otpBasePackage;
  findBasePackage = import ./findBasePackage.nix {inherit lib;};

  mkElixir = beamPkgs: version: sha256: let
    basePkg = elixirBasePackage beamPkgs version;
  in
    basePkg.override {inherit sha256 version;};

  mkErlang = pkgs: version: sha256: let
    basePkg = otpBasePackage pkgs version;
  in
    basePkg.override {inherit sha256 version;};
  versions = {
    elixir = importJSON ../data/elixir.json;
    erlang = importJSON ../data/erlang.json;
  };
in {
  inherit versions;
}
