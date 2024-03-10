# Usage

## Via Flake Template

### Default Template

```bash
nix flake init -t github:shanesveller/nix-beam-flakes#default
```

Current `flake.nix` content for this template is as follows:

```nix
{{#include ../templates/default/flake.nix}}
```

### Phoenix Template

```bash
nix flake init -t github:shanesveller/nix-beam-flakes#phoenix
```

At the time of writing there is no meaningful distinction between this template
and the `default` template, but they will diverge as I continue to implement
speciality support for the needs of a Phoenix project.

Current `flake.nix` content for this template is as follows:

```nix
{{#include ../templates/phoenix/flake.nix}}
```

## Manually Via `flake-parts`

Please review the documentation for flake-parts [here](https://flake.parts/) if
you are new to this library/paradigm.

A complete example:

```nix
{
  inputs = {
    # required
    beam-flakes.url = "github:shanesveller/nix-beam-flakes";
    flake-parts.url = "github:hercules-ci/flake-parts";
    # suggested
    beam-flakes.inputs.flake-parts.follows = "flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = inputs @ { beam-flakes, flake-parts, ... }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [beam-flakes.flakeModule];

      perSystem = _: {
        beamWorkspace = {
          enable = true;
          versions = {
            elixir = "...";
            erlang = "...";
          };
        };
      };
    };
}
```

You can add any additional packages to `perSystem.beamWorkspace.devShell.extraPackages`.

You can provide additional arguments to `mkShell`, such as arbitrary environment
variables, via `perSystem.beamWorkspace.devShell.extraArgs`.

You can opt out of the automatic `default` devShell and manage yourself by
setting `perSystem.beamWorkspace.devShell.enable = false;`

For more detail, see the full [options](options.md) guide.

## Setting Versions

### Explicitly

```nix
flake-parts.lib.mkFlake {inherit inputs;} {
  # ...
  perSystem = _: {
    beamWorkspace = {
      versions = {
        elixir = "1.14.2";
        erlang = "25.2";
      };
    };
  };
};
```

For `elixir`, you can also use an `asdf`-compatible string, such as `"1.14.2-otp-25"`.
Everything after the first hyphen is stripped and handled according to the defined
`erlang` version instead.

### `.tool-versions` Compatibility

For projects that formerly, or concurrently, use
[asdf](http://github.com/asdf-vm/asdf), a compatibility shim will read your
`.tool-versions` file and set the `elixir` and `erlang` versions accordingly.

This approach is mutually exclusive with the syntax [described above](#explicitly).

```
# .toolversions
elixir 1.16.2
erlang 26.2.3
```

```nix
flake-parts.lib.mkFlake {inherit inputs;} {
  # ...
  perSystem = _: {
    beamWorkspace = {
      enable = true;
      versions = {
        fromToolVersions = ./.tool-versions;
      };
    };
  };
};
```
