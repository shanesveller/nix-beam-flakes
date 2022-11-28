{self, ...}: {
  perSystem = {
    config,
    pkgs,
    ...
  }: let
    pkgSet = self.lib.packageSetFromToolVersions pkgs ../dev/example/.tool-versions {
      elixirLanguageServer = true;
      erlangLanguageServer = false;
    };
  in {
    checks.example = config.packages.example;

    packages = {
      example = pkgs.linkFarmFromDrvs "example-pkg-set" (builtins.attrValues pkgSet);
    };
  };
}
