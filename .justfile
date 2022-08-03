default: show

add-elixir version:
    nix run ./dev#add-elixir-version {{ version }}
add-erlang version:
    nix run ./dev#add-otp-version {{ version }}
check:
    nix flake check
    nix flake check ./dev
list-all-elixir:
    nix run ./dev#list-all-elixir
list-all-erlang:
    nix run ./dev#list-all-otp
show:
    nix flake show
