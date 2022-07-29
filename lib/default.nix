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

  mkPackageSet = {
    elixirVersion,
    erlangVersion,
    languageServers ? false,
    pkgs,
  }: let
    erlang = mkErlang pkgs erlangVersion versions.erlang.${erlangVersion};
    beamPkgs = pkgs.beam.packagesWith erlang;
    elixir = mkElixir beamPkgs elixirVersion versions.elixir.${elixirVersion};
  in
    {
      inherit (beamPkgs) erlang;
      inherit elixir;
    }
    // (
      if languageServers
      then {
        inherit (beamPkgs) erlang-ls;
        elixir_ls = beamPkgs.elixir_ls.override {inherit elixir;};
      }
      else {}
    );

  packageSetFromToolVersions = pkgs: toolVersionsPath: args: let
    asdfVersions = parseToolVersions toolVersionsPath;
  in
    mkPackageSet ({
        elixirVersion = asdfVersions.elixir;
        erlangVersion = asdfVersions.erlang;
        inherit pkgs;
      }
      // args);

  parseToolVersions = import ./parseToolVersions.nix {inherit lib;};

  versionCompatible = import ./versionCompatible.nix {
    inherit lib;
  };

  versions = {
    elixir = importJSON ../data/elixir.json;
    erlang = importJSON ../data/erlang.json;
  };
in {
  inherit compatibleVersions versions;
  inherit mkElixir mkErlang mkPackageSet;
  inherit packageSetFromToolVersions parseToolVersions;
}
