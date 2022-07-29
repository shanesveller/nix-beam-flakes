{
  self,
  lib,
  ...
}: {
  perSystem = {config, pkgs, ...}: let
    pkgSet = self.lib.mkPackageSet {
      inherit pkgs;
      elixirVersion = "1.13.4";
      erlangVersion = "24.3.4.2";
      languageServers = true;
    };
  in {
    checks.example = config.packages.example;

    legacyPackages = {erlang_24_3_4_2 = pkgSet.erlang;};

    packages = {
      example = pkgs.linkFarmFromDrvs "beam-overlay" (__attrValues pkgSet);
    };
  };
}
