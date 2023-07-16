_: {
  imports = [./credo-ls.nix ./livebook.nix ./phx_new.nix];

  perSystem = {
    config,
    pkgs,
    ...
  }: {
    packages.all =
      pkgs.linkFarmFromDrvs "nix-beam-flakes-packages"
      (with config.packages; [credo-language-server livebook phx_new]);
  };
}
