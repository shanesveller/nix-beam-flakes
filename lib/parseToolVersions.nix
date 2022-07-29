{lib}: let
  inherit (builtins) filter map listToAttrs readFile;
  inherit (lib.strings) splitString;
  inherit (lib.trivial) pipe;

  lineToPair = line: let
    columns = lib.strings.splitString " " line;
    lang = builtins.elemAt columns 0;
    version = builtins.elemAt columns 1;
  in
    lib.attrsets.nameValuePair lang version;
in
  path:
    pipe path [
      readFile
      (splitString "\n")
      (filter (line: line != ""))
      (map lineToPair)
      listToAttrs
    ]
