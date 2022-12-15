# Features

- Automatic packaging for ~any finalized, tagged release of both Erlang/OTP and
  Elixir
  - Package definitions are based on upstream `nixpkgs` definitions with `src`
    overrides
  - Packages will be added to your own flake's outputs, and can be consumed by
    other Nix code
- Declarative, automatic `devShell` creation using these packages (with opt-out)
  - Opt-in support for `elixir-ls` and `erlang_ls` LSP servers
- Elixir-ecosystem-aware Nix helpers
- A small number of [Elixir applications](packages.md) usable directly via `nix run`
- [Flake Templates](usage.md#via-flake-template)
