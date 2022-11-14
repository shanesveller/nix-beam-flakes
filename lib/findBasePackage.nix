_: let
  inherit (builtins) elemAt splitVersion;
in {
  elixirBasePackage = beamPkgs: version: let
    split = splitVersion version;
    major = elemAt split 0;
    minor = elemAt split 1;
  in
    beamPkgs."elixir_${major}_${minor}"
    or (throw "beam-flakes: Elixir version ${major}.${minor} has not been packaged in your nixpkgs input, but is needed");

  otpBasePackage = pkgs: version: let
    inherit (pkgs.beam) interpreters;
    major = elemAt (splitVersion version) 0;
  in
    interpreters."erlangR${major}"
    or (throw "beam-flakes: Erlang version ${major} has not been packaged in your nixpkgs input, but is needed");
}
