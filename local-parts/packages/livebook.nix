{lib, ...}: {
  perSystem = {
    config,
    pkgs,
    ...
  }: let
    beamPkgs = pkgs.beam.packages.erlangR26;
    # inherit (pkgs.callPackage ./lib.nix {inherit lib;}) buildEscript;
  in {
    packages = let
      inherit (beamPkgs) erlang rebar3;
      elixir = beamPkgs.elixir_1_15;
      hex = beamPkgs.hex.override {inherit elixir;};
      pname = "livebook";

      mixFodDeps = beamPkgs.fetchMixDeps {
        inherit elixir src version;
        pname = "mix-deps-${pname}";
        sha256 = "sha256-qFLCWr7LzI9WNgj0AJO3Tw7rrA1JhBOEpX79RMjv2nk=";
      };
      src = pkgs.fetchFromGitHub {
        owner = "livebook-dev";
        repo = "livebook";
        rev = "v${version}";
        sha256 = "sha256-Bp1CEvVv5DPDDikRPubsG6p4LLiHXTEXE+ZIip3LsGA=";
      };
      # https://github.com/livebook-dev/livebook/releases
      version = "0.10.0";
    in {
      livebook = beamPkgs.mixRelease {
        buildInputs = [];
        nativeBuildInputs = [pkgs.makeWrapper];

        inherit elixir hex mixFodDeps pname src version;

        installPhase = ''
          mix escript.build

          mkdir -p $out/bin
          cp ./livebook $out/bin

          wrapProgram $out/bin/livebook \
            --prefix PATH : ${lib.makeBinPath [elixir erlang]} \
            --set MIX_REBAR3 ${rebar3}/bin/rebar3
        '';
      };

      livebook_bumblebee = beamPkgs.mixRelease {
        buildInputs = [];
        nativeBuildInputs = [pkgs.makeWrapper];

        inherit elixir hex mixFodDeps pname src version;

        installPhase = ''
          mix escript.build

          mkdir -p $out/bin
          cp ./livebook $out/bin

          wrapProgram $out/bin/livebook \
            --prefix PATH : ${lib.makeBinPath [elixir erlang pkgs.stdenv]} \
            --set MIX_REBAR3 ${rebar3}/bin/rebar3
        '';
      };
    };
  };
}
