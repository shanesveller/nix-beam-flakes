default: show

add-elixir version:
    nix run ./dev#add-elixir-version {{ version }}
add-erlang version:
    nix run ./dev#add-otp-version {{ version }}
check:
    nix flake check
    nix flake check ./dev
doc:
  nix build .#optionsDoc
  cat ./result > docs/options.md
list-all-elixir:
    nix run ./dev#list-all-elixir
list-all-erlang:
    nix run ./dev#list-all-otp
show:
    nix flake show
watch-docs:
  nix develop .#docs --command mdbook serve --open
