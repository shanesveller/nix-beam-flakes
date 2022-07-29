{lib, ...}: let
  myLib = import ../lib {inherit lib;};
in {
  flake.lib = myLib;
}
