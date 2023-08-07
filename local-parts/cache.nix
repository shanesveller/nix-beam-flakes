{
  inputs,
  lib,
  self,
  ...
}: {
  flake = let
    inherit (lib.trivial) pipe;
    inherit (self.lib) recentElixirs recentErlangs versionCompatible;

    checks = {
      x86_64-linux =
        lib.attrsets.genAttrs self.lib.recentElixirs (v: "elixir");
    };

    compatible = pipe [recentElixirs recentErlangs] [
      (lib.lists.crossLists (elixir: erlang: {inherit elixir erlang;}))
      lib.debug.traceValSeq
      (builtins.filter (attrs: versionCompatible attrs.elixir attrs.erlang))
      lib.debug.traceValSeq
    ];
  in {
    githubActions = inputs.nix-github-actions.lib.mkGithubMatrix {inherit checks;};
    inherit compatible;
  };
}
