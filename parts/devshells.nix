{self, ...}: {
  perSystem = {
    config,
    inputs',
    pkgs,
    self',
    ...
  }: {
    devShells.default = pkgs.mkShell {buildInputs = [];};
  };
}
