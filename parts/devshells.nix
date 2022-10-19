{self, ...}: {
  perSystem = {pkgs, ...}: let
    mkBeamShell = pkgSet:
      pkgs.mkShell {
        packages = with pkgSet; [elixir elixir_ls erlang erlang-ls];

        shellHook = ''
          elixir --version
          erl -eval '{ok, Version} = file:read_file(filename:join([code:root_dir(), "releases", erlang:system_info(otp_release), "OTP_VERSION"])), io:fwrite(Version), halt().' -noshell
        '';
      };
  in {
    devShells.asdf = let
      pkgSet = self.lib.packageSetFromToolVersions pkgs ../test/.tool-versions {
        languageServers = true;
      };
    in
      mkBeamShell pkgSet;

    devShells.example = let
      pkgSet = self.lib.mkPackageSet {
        inherit pkgs;
        elixirVersion = "1.14.1";
        erlangVersion = "25.1.1";
        languageServers = true;
      };
    in
      mkBeamShell pkgSet;
  };
}
