{
  inputs,
  lib,
  ...
}: {
  flake.overlays.elixir_prerelease = final: prev: let
    elixir_1_15 = prev.beam.beamLib.callElixir ./elixir_1_15.nix {
      inherit (prev.beamPackages) erlang;
      debugInfo = true;
    };
  in {
    beam =
      prev.beam
      // {
        interpreters =
          prev.beam.interpreters
          // {
            inherit elixir_1_15;
          };
      };
    beamPackages = prev.beamPackages.extend (self: super: {
      inherit elixir_1_15;
      erlangR26 = prev.beamPackages.erlangR26.extend (self: super: {
        # elixir_1_15 = elixir_1_15.override {inherit (self) erlang;};
        inherit elixir_1_15;
      });
    });
  };
}
