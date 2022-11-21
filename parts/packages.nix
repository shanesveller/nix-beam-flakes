{self, ...}: {
  imports = [./packages/livebook.nix ./packages/phx_new.nix];

  perSystem = {
    config,
    pkgs,
    ...
  }: let
    pkgSet = self.lib.packageSetFromToolVersions pkgs ../test/.tool-versions {
      elixirLanguageServer = true;
      erlangLanguageServer = false;
    };
  in {
    checks.example = config.packages.example;

    legacyPackages = self.lib.compatibleVersionPackages pkgs;

    packages = {
      example = pkgs.linkFarmFromDrvs "beam-overlay" (builtins.attrValues pkgSet);
    };
  };
}
