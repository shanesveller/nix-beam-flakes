{lib}: let
  inherit (builtins) elemAt splitVersion;
in {
  elixirBasePackage = beamPkgs: version: let
    split = splitVersion version;
    major = elemAt split 0;
    minor = elemAt split 1;
  in
    if beamPkgs ? "elixir_${major}_${minor}"
    then beamPkgs."elixir_${major}_${minor}"
    else null;

  otpBasePackage = pkgs: version: let
    inherit (pkgs.beam) interpreters;
    major = elemAt (splitVersion version) 0;
  in
    if interpreters ? "erlangR${major}"
    then interpreters."erlangR${major}"
    else null;
}
