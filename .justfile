default: show

add-elixir version:
    nix run ./dev#add-elixir-version {{ version }}
add-erlang version:
    nix run ./dev#add-otp-version {{ version }}
check:
    nix flake check --all-systems
    nix flake check ./dev --all-systems
doc:
  nix build .#optionsDoc
  cat ./result > docs/options.md
list-all-elixir:
    nix run ./dev#list-all-elixir
list-all-erlang:
    nix run ./dev#list-all-otp
show:
    nix flake show

target_ref := `nix flake metadata --json github:shanesveller/nix-flake-lock-targets | jq -r '.locks.nodes.unstable.locked.rev'`
update_args := "--commit-lock-file --override-input nixpkgs github:nixos/nixpkgs/" + target_ref
update: update-inputs
update-inputs:
  nix flake update {{ update_args }} .
  nix flake update {{ update_args }} ./dev

watch-docs:
  nix develop .#docs --command mdbook serve --open
