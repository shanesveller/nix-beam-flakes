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

    legacyPackages = self.lib.compatibleVersionPackages pkgs;

    packages = {
      example = pkgs.linkFarmFromDrvs "beam-overlay" (__attrValues pkgSet);
    };
  };
}
