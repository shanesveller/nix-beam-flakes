# Nix tooling for Flakes and BEAM Languages

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->

**Table of Contents**

- [Requirements](#requirements)
- [Features](#features)
  - [Packages](#packages)
    - [phx_new](#phx_new)
    - [livebook](#livebook)
- [Usage](#usage)
  - [Via Flake Template](#via-flake-template)
  - [Manually Via `flake-parts`](#manually-via-flake-parts)
- [Setting Versions](#setting-versions)
  - [Explicitly](#explicitly)
  - [`.tool-versions` Compatibility](#tool-versions-compatibility)
- [Future Plans](#future-plans)
- [Contributing](#contributing)
  - [Newly-published language versions](#newly-published-language-versions)
  - [Other Beam Languages](#other-beam-languages)
  - [Other Details](#other-details)
- [Credits](#credits)

<!-- markdown-toc end -->

## Requirements

- Nix with Flakes support
- [flake-parts](https://github.com/hercules-ci/flake-parts)
- `direnv` (Optional)

## Features

- Automatic packaging for ~any finalized, tagged release of both Erlang/OTP and
  Elixir
  - Package definitions are based on upstream `nixpkgs` definitions with `src`
    overrides
  - Packages will be added to your own flake's outputs, and can be consumed by
    other Nix code
- Declarative, automatic `devShell` creation using these packages (with opt-out)
  - Opt-in support for `elixir-ls` and `erlang_ls` LSP servers
- Elixir-ecosystem-aware Nix helpers
- A small number of Elixir applications usable directly via `nix run` (see below)
- [Flake Templates](#via-template)

### Packages

#### phx_new

Want to start a new Phoenix project? Don't have a global install of Elixir/Mix?
This can help. Pairs well with flake templates below.

```shell
nix run github:shanesveller/nix-beam-flakes#phx_new -- --help
```

#### livebook

```shell
nix run github:shanesveller/nix-beam-flakes#livebook -- server
```

## Usage

### Via Flake Template

```shell
nix flake init -t github:shanesveller/nix-beam-flakes#default
# or
nix flake init -t github:shanesveller/nix-beam-flakes#phoenix
```

At the time of writing there is no meaningful distinction between the two, but
they will diverge as I continue to implement speciality support for the needs of
a Phoenix project.

### Manually Via `flake-parts`

Please review the documentation for flake-parts [here](https://flake.parts/) if
you are new to this library/paradigm.

A complete example:

```nix
{
  description = "My Elixir application";

  inputs = {
    beam-flakes.url = "github:shanesveller/nix-beam-flakes";
    beam-flakes.inputs.flake-parts.follows = "flake-parts";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = {
    self,
    beam-flakes,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit self;} {
      imports = [beam-flakes.flakeModule];

      systems = ["aarch64-darwin" "x86_64-darwin" "x86_64-linux"];

      perSystem = _: {
        beamWorkspace = {
          enable = true;
          devShell.languageServers.elixir = true;
          versions = {
            elixir = "1.15.5";
            erlang = "26.1";
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

## Setting Versions

### Explicitly

```nix
    flake-parts.lib.mkFlake {inherit self;} {
      # ...
      perSystem = _: {
        beamWorkspace = {
          versions = {
            # You can also use an `asdf`-compatible string, such as "1.14.2-otp-25".
            #
            # Everything after the first hyphen is stripped and handled according
            # to the defined erlang version instead.
            elixir = "1.15.5";
            erlang = "26.1";
          };
        };
      };
    };
```

### `.tool-versions` Compatibility

For projects that formerly, or concurrently, use
[asdf](http://github.com/asdf-vm/asdf), a compatibility shim will read your
`.tool-versions` file and set the `elixir` and `erlang` versions accordingly.

```nix
    flake-parts.lib.mkFlake {inherit self;} {
      # ...
      perSystem = _: {
        beamWorkspace = {
          enable = true;
          versions = {
            fromToolVersioons = ./.tool-versions;
          };
        };
      };
    };
```

## Future Plans

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

## Contributing

Generally not solicited at this time, but if you're particularly adventurous,
read on.

### Newly-published language versions

If you are a Nix user, this is already automated:

```shell
nix develop ./dev
just add-elixir 1.15.5
just add-erlang 26.1
```

Just PR the changes to `data` that it committed for you. I'll probably be on top
of it already, for the most part.

### Other Beam Languages

At this time I am not a personal or professional user of any other languages
that inhabit the BEAM VM, and I do not feel I can offer a satisfactory level of
support or nuance for tooling I do not use. As such, I will consider
collaborating with those who do to offer support here on a best-effort basis,
but I do not consider it a priority at this time.

### Other Details

Please open an issue/discussion before setting out on any other contributions so
that we can discuss whether your ideas align with my plans for this project. I'd
hate to see anyone feel like their effort/goodwill were wasted.

## Credits

I would not have pushed this very far were it not for flakes and
[flake-parts](https://github.com/hercules-ci/flake-parts). I've gotten several
rounds of useful feedback directly from discussions on the `flake-parts`
repository as well as learned a lot from studying its code.

I also take some inspiration from
[`oxalica/rust-overlay`](https://github.com/oxalica/rust-overlay).
