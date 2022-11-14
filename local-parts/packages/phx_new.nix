{lib, ...}: {
  perSystem = {pkgs, ...}: let
    beamPkgs = pkgs.beam.packages.erlangR24;
    buildMixArchive = {
      elixir,
      hex,
      pname,
      rebar,
      rebar3,
      src,
      version,
      DEBUG ? 0,
      MIX_ENV ? "prod",
    }:
      pkgs.stdenv.mkDerivation {
        inherit src version;
        pname = "${pname}-archive";
        nativeBuildInputs = [elixir hex];

        inherit DEBUG;
        HEX_OFFLINE = 1;
        MIX_DEBUG = DEBUG;
        inherit MIX_ENV;
        MIX_REBAR = lib.getExe rebar;
        MIX_REBAR3 = lib.getExe rebar3;

        phases = ["unpackPhase" "buildPhase" "installPhase"];

        postUnpack = ''
          export HEX_HOME="$TEMPDIR/hex"
          export MIX_HOME="$TEMPDIR/mix"
          export REBAR_CACHE_DIR="$TEMPDIR/rebar3.cache"
          export REBAR_GLOBAL_CONFIG_DIR="$TEMPDIR/rebar3"
        '';

        buildPhase = ''
          mix archive.build
        '';

        installPhase = ''
          MIX_HOME="$out" mix archive.install --force
        '';
      };
    wrapMixCommand = {
      archive,
      elixir,
      erlang,
      git ? pkgs.gitMinimal,
      hex,
      pname,
      subcommand,
    }:
      pkgs.writeShellApplication {
        name = pname;
        runtimeInputs = [erlang elixir git hex];
        text = ''
          export MIX_HOME="${archive}"

          case $1 in
            help | "--help")
              exec mix help ${subcommand}
              ;;
            *)
              exec mix ${subcommand} "$@"
              ;;
          esac
        '';
      };
  in {
    packages = let
      inherit (beamPkgs) erlang rebar rebar3;
      elixir = beamPkgs.elixir_1_14;
      hex = beamPkgs.hex.override {inherit elixir;};
      pname = "phx_new";
      subcommand = "phx.new";
    in {
      phx_new = let
        version = "1.6.15";
        # https://github.com/phoenixframework/phoenix/tags
        src = pkgs.fetchFromGitHub {
          owner = "phoenixframework";
          repo = "phoenix";
          rev = "v${version}";
          sha256 = "sha256-zw3FsOGc5zF3fgfAUekvedCdHFKOSgmlCfZkmPqFF7U=";
        };
      in
        wrapMixCommand {
          inherit elixir erlang hex pname subcommand;
          archive = buildMixArchive {
            inherit elixir hex pname rebar rebar3 version;
            src = "${src}/installer";
          };
        };

      phx_new_unstable = let
        version = "1.7.0-rc.0";
        # https://github.com/phoenixframework/phoenix/commits/master/installer
        src = pkgs.fetchFromGitHub {
          owner = "phoenixframework";
          repo = "phoenix";
          rev = "v1.7.0-rc.0";
          sha256 = "sha256-kCAC3dj9wbPKQss7JA6JE30VYYnKpGUPX3aSp0ZOjho=";
        };
      in
        wrapMixCommand {
          inherit elixir erlang hex pname subcommand;
          archive = buildMixArchive {
            inherit elixir hex pname rebar rebar3 version;
            src = "${src}/installer";
          };
        };
    };
  };
}
