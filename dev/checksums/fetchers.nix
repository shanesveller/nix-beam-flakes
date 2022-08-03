{...}: {
  perSystem = {pkgs, ...}: {
    packages = {
      nix-prefetch-elixir = pkgs.writeShellScriptBin "nix-prefetch-elixir" ''
        ${pkgs.nix}/bin/nix-prefetch-url --unpack https://github.com/elixir-lang/elixir/archive/v''${1}.tar.gz
      '';

      nix-prefetch-otp = pkgs.writeShellScriptBin "nix-prefetch-otp" ''
        ${pkgs.nix}/bin/nix-prefetch-url --unpack https://github.com/erlang/otp/archive/OTP-''${1}.tar.gz
      '';
    };
  };
}
