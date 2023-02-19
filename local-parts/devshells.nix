{
  lib,
  self,
  ...
}: {
  perSystem = {pkgs, ...}: let
    mkBeamShell = pkgSet:
      pkgs.mkShell {
        packages =
          (with pkgSet; [elixir erlang])
          ++ lib.optional (pkgSet ? "elixir_ls") pkgSet.elixir_ls
          ++ lib.optional (pkgSet ? "erlang-ls") pkgSet.erlang-ls;

        shellHook = ''
          elixir --version
          erl -eval '{ok, Version} = file:read_file(filename:join([code:root_dir(), "releases", erlang:system_info(otp_release), "OTP_VERSION"])), io:fwrite(Version), halt().' -noshell
        '';
      };
  in {
    devShells.asdf = let
      pkgSet = self.lib.packageSetFromToolVersions pkgs ../dev/example/.tool-versions {
        elixirLanguageServer = true;
      };
    in
      mkBeamShell pkgSet;

    devShells.example = let
      pkgSet = self.lib.mkPackageSet {
        inherit pkgs;
        elixirVersion = "1.14.3";
        erlangVersion = "25.2.3";
        elixirLanguageServer = true;
      };
    in
      mkBeamShell pkgSet;
  };
}
