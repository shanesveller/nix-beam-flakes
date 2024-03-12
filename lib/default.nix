{lib}: let
  inherit (builtins) concatStringsSep mapAttrs splitVersion;
  inherit (lib) take;
  inherit (lib.attrsets) filterAttrs mapAttrs' nameValuePair;
  inherit (lib.trivial) importJSON pipe;
  inherit (findBasePackage) elixirBasePackage otpBasePackage;

  compatibleVersions = let
    elixirsFor = erlangVersion:
      pipe versions.elixir [
        (filterAttrs (n: _v: versionCompatible n erlangVersion))
        (mapAttrs (version: checksum: {inherit version checksum;}))
      ];
    genCompatiblePkgSet = version: checksum:
      nameValuePair version {
        erlang = {inherit version checksum;};
        elixirs = elixirsFor version;
      };
  in
    mapAttrs' genCompatiblePkgSet versions.erlang;

  compatibleVersionPackages = pkgs: let
    expandElixir = erlang: _name: attrs:
      if erlang != null
      then
        nameValuePair "elixir_${attrs.version}"
        (mkElixir (pkgs.beam.packagesWith erlang) attrs.version attrs.checksum)
      else null;
    expandErlang = _erlangVersion: checksumSet: let
      erlang =
        mkErlang pkgs checksumSet.erlang.version
        checksumSet.erlang.checksum;
      elixirs = pipe checksumSet.elixirs [
        (mapAttrs' (expandElixir erlang))
        (filterAttrs (_n: v: v != null))
      ];
    in
      nameValuePair "erlang_${erlang.version}" {inherit erlang elixirs;};
  in
    pipe compatibleVersions [
      (filterAttrs (erlangVersion: _attrs: (erlangExists pkgs erlangVersion)))
      (mapAttrs' expandErlang)
    ];

  erlangExists = pkgs: version: otpBasePackage pkgs version != null;

  findBasePackage = import ./findBasePackage.nix {inherit lib;};

  latestVersions = import ./latestVersions.nix {inherit lib versions;};

  mkElixir = beamPkgs: version: sha256: let
    basePkg = elixirBasePackage beamPkgs version;
  in
    if basePkg != null
    then basePkg.override {inherit sha256 version;}
    else null;

  mkErlang = pkgs: version: sha256: let
    basePkg = otpBasePackage pkgs version;
  in
    if basePkg != null
    then basePkg.override {inherit sha256 version;}
    else null;

  mkPackageSet = {
    elixirVersion,
    erlangVersion,
    elixirLanguageServer ? false,
    erlangLanguageServer ? false,
    # Upstream Rebar project is presumed to have done its own CI diligence WRT Erlang versions
    rebarCheck ? false,
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
      if elixirLanguageServer
      then {
        elixir-ls = (beamPkgs.elixir-ls.override {inherit elixir;}).overrideAttrs (old: {
          buildPhase =
            # Elixir 1.16.0 or newer
            if ((builtins.compareVersions elixir.version "1.16.0") != -1)
            then ''
              runHook preBuild
              mix do compile --no-deps-check, elixir_ls.release2
              runHook postBuild
            ''
            else old.buildPhase;
        });
      }
      else {}
    )
    // (
      if erlangLanguageServer
      then {
        inherit (beamPkgs) erlang-ls;
      }
      else {}
    )
    // (
      if rebarCheck
      then {}
      else lib.genAttrs ["rebar" "rebar3"] (p: beamPkgs.${p}.overrideAttrs (_old: {doCheck = false;}))
    );

  normalizeElixir = version:
    lib.trivial.pipe version [
      (lib.versions.pad 3)
      splitVersion
      (take 3)
      (map toString)
      (concatStringsSep ".")
    ];

  packageSetFromToolVersions = pkgs: toolVersionsPath: args: let
    asdfVersions = parseToolVersions toolVersionsPath;
  in
    mkPackageSet ({
        elixirVersion = normalizeElixir asdfVersions.elixir;
        erlangVersion = asdfVersions.erlang;
        inherit pkgs;
      }
      // args);

  parseToolVersions = import ./parseToolVersions.nix {inherit lib;};

  inherit (latestVersions) recentElixirs recentErlangs;

  # idea credit: https://github.com/nix-community/nix-github-actions/blob/bfeb681177b5128d061ebbef7ded30bc21a3f135/default.nix
  recentMatrix =
    pipe {
      elixir = recentElixirs;
      erlang = recentErlangs;
      os = ["macos-14" "ubuntu-latest"];
    } [
      lib.attrsets.cartesianProductOfSets
      (builtins.filter (set: versionCompatible set.elixir set.erlang))
      (v: {include = v;})
    ];

  versionCompatible =
    import ./versionCompatible.nix {inherit lib normalizeElixir;};

  versions = {
    elixir = importJSON ../data/elixir.json;
    erlang = importJSON ../data/erlang.json;
  };
in {
  inherit compatibleVersions compatibleVersionPackages versions versionCompatible;
  inherit mkElixir mkErlang mkPackageSet normalizeElixir;
  inherit packageSetFromToolVersions parseToolVersions;
  inherit (latestVersions) latestElixirMinors latestErlangMajors recentElixirs recentErlangs;
  inherit recentMatrix;
}
