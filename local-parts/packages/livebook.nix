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

      livebook_bumblebee = let
        # NOTE: MacOS EXLA build process apparently ignores the Nix-provided GCC
        #       for `clang++` from PATH
        compiler =
          if pkgs.stdenv.isLinux
          then pkgs.gcc
          else pkgs.clang;
        inherit (pkgs.darwin.apple_sdk) frameworks;
        # NOTE: Can't use lib.optionalString in tail position due to eval errors on Linux
        frameworkFlags =
          if pkgs.stdenv.isDarwin
          then
            lib.trivial.pipe [frameworks.Foundation]
            [
              (builtins.map (p: "-F${p}/Library/Frameworks"))
              (builtins.concatStringsSep " ")
              lib.escapeShellArg
            ]
          else "";
      in
        pkgs.symlinkJoin {
          name = "livebook-with-bumblee-compiler";
          paths = [config.packages.livebook];
          buildInputs = [pkgs.makeWrapper];
          postBuild = ''
            wrapProgram $out/bin/livebook \
              --prefix NIX_LDFLAGS ' ' ${frameworkFlags} \
              --prefix PATH : ${lib.makeBinPath (with pkgs; [cmake compiler gnumake])}
          '';

          meta.mainProgram = "livebook";
        };
    };
  };
}
