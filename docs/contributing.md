# Contributing

Generally not solicited at this time, but if you're particularly adventurous,
read on.

## Newly-published language versions

If you are a Nix user, this is already automated:

```shell
nix develop ./dev
just add-elixir 1.15.7
just add-erlang 26.1.2
```

Just PR the changes to `data` that it committed for you. I'll probably be on top
of it already, for the most part.

## Other Beam Languages

At this time I am not a personal or professional user of any other languages
that inhabit the BEAM VM, and I do not feel I can offer a satisfactory level of
support or nuance for tooling I do not use. As such, I will consider
collaborating with those who do to offer support here on a best-effort basis,
but I do not consider it a priority at this time.

## Nix

All code in this repository should be formatted with `alejandra` and is
optionally managed via `pre-commit-hooks.nix`.

## Other Details

Please open an issue/discussion before setting out on any other contributions so
that we can discuss whether your ideas align with my plans for this project. I'd
hate to see anyone feel like their effort/goodwill were wasted.
