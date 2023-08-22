# Future Plans

Immediate concerns:

- [ ] Significant documentation efforts inspired by the `flake-parts` website
- [x] CI that the modules continue to evaluate successfully with common scenarios
- [x] A binary cache for the latest pairing of Erlang/Elixir for MacOS/Linux
- [ ] More robust specialty support for Phoenix projects

Later on:

- Expose/enforce the compatibility-check logic that honors [Elixir's
  compatibility
  policy](https://hexdocs.pm/elixir/compatibility-and-deprecations.html) so
  flake users get immediate feedback when they've chosen an unsupported
  combination
- Phoenix speciality support
  - `esbuild` binaries
  - `tailwind` binaries
  - Possibly some lightweight Node.js support

Future:

- [pre-commit-hooks.nix](https://github.com/cachix/pre-commit-hooks.nix)
  integration with canned Elixir-specific hooks - it already pairs nicely using the `flake-parts` module
- Automatic Docker-compatible OCI image creation from your Mix release via
  [`pkgs.ociTools`](https://nixos.org/manual/nixpkgs/stable/#sec-pkgs-ociTools)
- NixOS module generation to run your Mix release via `systemd`
