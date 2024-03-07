{
  self,
  inputs,
  lib,
  flake-parts-lib,
  ...
}: {
  perSystem = {pkgs, ...}: let
    eval = flake-parts-lib.evalFlakeModule {
      inherit inputs;
      specialArgs = {
        inherit pkgs;
        beam-flake-lib = self.lib;
      };
    } {imports = [../parts/all-parts.nix];};

    filterOptions = option:
      option
      // {
        visible = lib.hasPrefix "perSystem.beamWorkspace" option.name;
      };

    optionsDoc = pkgs.nixosOptionsDoc {
      options = builtins.removeAttrs eval.options [
        # Upstream flake-parts
        "_module"
        "flake"
        "perInput"
        # Focused via filterOptions instead
        # "perSystem"
        "systems"
        "transposition"
      ];
      documentType = "none";
      warningsAreErrors = false;
      markdownByDefault = true;
      transformOptions = filterOptions;
    };
  in {
    devShells.docs = pkgs.mkShell {
      packages = [pkgs.mdbook];
    };

    packages.docs = pkgs.runCommand "beam-flakes-mdbook" {} ''
      mkdir $TMP/src
      ln -s ${self}/book.toml $TMP/book.toml
      ln -s ${self}/templates $TMP/templates
      cp -r ${self}/docs $TMP/docs
      chmod u+w $TMP/docs
      ln -s ${optionsDoc.optionsCommonMark} $TMP/docs/options.md
      ${lib.getExe' pkgs.mdbook "mdbook"} build -d $out $TMP/
    '';

    packages.optionsDoc = optionsDoc.optionsCommonMark;
  };
}
