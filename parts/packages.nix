{
  self,
  lib,
  ...
}: {
  perSystem = {
    config,
    pkgs,
    ...
  }: let
    pkgSet = self.lib.packageSetFromToolVersions pkgs ../test/.tool-versions {
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
