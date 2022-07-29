{lib}: let
  inherit (builtins) concatStringsSep splitVersion;
  inherit (lib) take;
  inherit (lib.attrsets) filterAttrs mapAttrs' nameValuePair;
  inherit (lib.trivial) importJSON;
  inherit (findBasePackage) elixirBasePackage otpBasePackage;

  compatibleVersions = let
    elixirsFor = erlangVersion:
      filterAttrs (n: _v: versionCompatible n erlangVersion) versions.elixir;
    genCompatiblePkgSet = version: checksum:
      nameValuePair version {
        erlang = checksum;
        elixirs = elixirsFor version;
      };
  in
    mapAttrs' genCompatiblePkgSet versions.erlang;

  findBasePackage = import ./findBasePackage.nix {inherit lib;};

  mkElixir = beamPkgs: version: sha256: let
    basePkg = elixirBasePackage beamPkgs version;
  in
    basePkg.override {inherit sha256 version;};

  mkErlang = pkgs: version: sha256: let
    basePkg = otpBasePackage pkgs version;
  in
    basePkg.override {inherit sha256 version;};

  versionCompatible = import ./versionCompatible.nix {
    inherit lib;
  };

  versions = {
    elixir = importJSON ../data/elixir.json;
    erlang = importJSON ../data/erlang.json;
  };
in {
  inherit compatibleVersions versions;
}
