{lib, ...}: let
  myLib = import ../lib {inherit lib;};
in {
  flake.lib = myLib;
  _module.args.beam-flakes-lib = myLib;
}
