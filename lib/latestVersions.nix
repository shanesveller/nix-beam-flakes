{
  lib,
  versions,
  ...
}: let
  inherit (builtins) attrNames attrValues compareVersions sort;
  inherit (lib.attrsets) getAttrs;
  inherit (lib.lists) groupBy' reverseList take;
  inherit (lib.strings) concatStringsSep;
  inherit (lib.trivial) pipe;
  inherit (lib.versions) splitVersion;

  extractMajor = lib.versions.major;
  extractMajorMinor = v:
    pipe v [
      (lib.versions.pad 2)
      splitVersion
      (take 2)
      (concatStringsSep ".")
    ];

  keepHighest = v1: v2:
    if (compareVersions v1 v2) == -1
    then v2
    else v1;

  lesserVersion = l: r: compareVersions l r == -1;

  keepLatestThree = attrset:
    pipe attrset [
      attrNames
      (sort lesserVersion)
      reverseList
      (take 3)
      (chosen: getAttrs chosen attrset)
      attrValues
    ];

  latestElixirMinors = let
    versionNames = attrNames versions.elixir;
  in
    groupBy' keepHighest "0.0.0" extractMajorMinor versionNames;

  latestErlangMajors = let
    versionNames = attrNames versions.erlang;
  in
    groupBy' keepHighest "0.0.0" extractMajor versionNames;

  recentElixirs = keepLatestThree latestElixirMinors;
  recentErlangs = keepLatestThree latestErlangMajors;
in {
  inherit
    extractMajor
    extractMajorMinor
    keepHighest
    latestElixirMinors
    latestErlangMajors
    recentElixirs
    recentErlangs
    ;
}
