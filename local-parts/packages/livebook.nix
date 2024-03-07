{lib, ...}: {
  perSystem = {
    config,
    pkgs,
    ...
  }: let
    beamPkgs = pkgs.beam.packages.erlangR26.extend (_final: prev: {
      rebar3 = prev.rebar3.overrideAttrs (_old: {doCheck = false;});
    });
  in {
    packages = let
      inherit (beamPkgs) erlang rebar3;
      elixir = beamPkgs.elixir_1_15;
      hex = beamPkgs.hex.override {inherit elixir;};
      pname = "livebook";

      mixFodDeps = beamPkgs.fetchMixDeps {
        inherit elixir src version;
        pname = "mix-deps-${pname}";
        sha256 = "sha256-x/VvXB2rJ03c3tWZRXnD3gbTT494P8GVD0sYEHcTp3o=";
      };
      src = pkgs.fetchFromGitHub {
        owner = "livebook-dev";
        repo = "livebook";
        rev = "v${version}";
        sha256 = "sha256-Q4c0AelZZDPxE/rtoHIRQi3INMLHeiZ72TWgy183f4Q=";
      };
      # https://github.com/livebook-dev/livebook/releases
      version = "0.12.1";
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

        meta.mainProgram = "livebook";
      };

      livebook_bumblebee = pkgs.symlinkJoin {
        name = "livebook-with-gcc";
        paths = with pkgs; [cmake gcc gnumake config.packages.livebook];
        buildInputs = [pkgs.makeWrapper];
        postBuild = ''
          wrapProgram $out/bin/livebook \
            --prefix PATH : ${lib.makeBinPath (with pkgs; [cmake gcc gnumake])}
        '';

        meta.mainProgram = "livebook";
      };
    };
  };
}
