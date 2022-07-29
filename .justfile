default: show

add-elixir version:
    nix run .#add-elixir-version {{ version }}
add-erlang version:
    nix run .#add-otp-version {{ version }}
check:
    nix flake check
    nix flake check ./dev
list-all-elixir:
    nix run .#list-all-elixir
list-all-erlang:
    nix run .#list-all-otp
show:
    nix flake show
