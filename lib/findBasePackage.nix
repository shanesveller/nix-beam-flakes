{lib}: let
  inherit (builtins) elemAt splitVersion;
in {
  elixirBasePackage = beamPkgs: version: let
    split = splitVersion version;
    major = elemAt split 0;
    minor = elemAt split 1;
  in
    beamPkgs."elixir_${major}_${minor}";

  otpBasePackage = pkgs: version: let
    major = elemAt (splitVersion version) 0;
  in
    pkgs.beam.interpreters."erlangR${major}";
}
