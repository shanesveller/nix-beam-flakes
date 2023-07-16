{lib, ...}: {
  perSystem = {
    config,
    pkgs,
    ...
  }: let
    beamPkgs = pkgs.beam.packages.erlangR25;
  in {
    packages = let
      inherit (beamPkgs) elixir erlang hex;
      pname = "credo-language-server";

      mixFodDeps = beamPkgs.fetchMixDeps {
        inherit elixir src version;
        pname = "mix-deps-${pname}";
        sha256 = "sha256-1yqstmhwGag5/1cogHUWaTtL3egepVCFn73A3lXkdwI=";
      };
      src = pkgs.fetchFromGitHub {
        owner = "elixir-tools";
        repo = "credo-language-server";
        rev = "v${version}";
        sha256 = "sha256-IHgv8KliJSTPvRg9YeOIn9lrkv0+EYI+O/OpNQ1R9co=";
      };
      version = "0.2.0";
    in {
      credo-language-server = beamPkgs.mixRelease {
        buildInputs = [];
        nativeBuildInputs = [pkgs.makeWrapper];

        inherit elixir hex mixFodDeps pname src version;

        patches = [./credo-ls.patch];

        installPhase = ''
          mix escript.build

          mkdir -p $out/bin
          cp credo_language_server $out/bin
          wrapProgram $out/bin/credo_language_server \
            --prefix PATH : ${lib.makeBinPath [elixir erlang]}
        '';
      };
    };
  };
}
