_: {
  imports = [./livebook.nix ./phx_new.nix];

  perSystem = {
    config,
    pkgs,
    ...
  }: {
    packages.all =
      pkgs.linkFarmFromDrvs "nix-beam-flakes-packages"
      (with config.packages; [livebook phx_new]);
  };
}
