{
  lib,
  normalizeElixir,
}: elixir: erlang: let
  inherit (builtins) concatStringsSep length map splitVersion toString;
  inherit (lib.lists) findFirst;
  inherit (lib.strings) versionAtLeast versionOlder;

  # max is exclusive, range is [)
  # https://hexdocs.pm/elixir/main/compatibility-and-deprecations.html
  # https://hexdocs.pm/elixir/main/compatibility-and-deprecations.html#compatibility-between-elixir-and-erlang-otp
  bounds = [
    # 1.15.0-dev
    {
      min_erl = "24.0.0";
      max_erl = "27.0.0";
      min_el = "1.15.0";
      max_el = "1.16.0";
    }
    {
      min_erl = "23.0.0";
      max_erl = "26.0.0";
      min_el = "1.14.0";
      max_el = "1.15.0";
    }
    {
      min_erl = "22.0.0";
      max_erl = "25.0.0";
      min_el = "1.12.0";
      max_el = "1.14.0";
    }
    {
      min_erl = "22.0.0";
      max_erl = "25.0.0";
      min_el = "1.12.0";
      max_el = "1.14.0";
    }
    {
      min_erl = "21.0.0";
      max_erl = "25.0.0";
      min_el = "1.11.4";
      max_el = "1.12.0";
    }
    {
      min_erl = "21.0.0";
      max_erl = "24.0.0";
      min_el = "1.11.0";
      max_el = "1.11.3";
    }
    {
      min_erl = "21.0.0";
      max_erl = "24.0.0";
      min_el = "1.10.3";
      max_el = "1.11.0";
    }
    {
      min_erl = "21.0.0";
      max_erl = "23.0.0";
      min_el = "1.10.0";
      max_el = "1.10.3";
    }
    {
      min_erl = "20.0.0";
      max_erl = "23.0.0";
      min_el = "1.8.0";
      max_el = "1.10.0";
    }
    {
      min_erl = "19.0.0";
      max_erl = "23.0.0";
      min_el = "1.7.0";
      max_el = "1.8.0";
    }
    {
      min_erl = "19.0.0";
      max_erl = "22.0.0";
      min_el = "1.6.6";
      max_el = "1.7.0";
    }
    {
      min_erl = "19.0.0";
      max_erl = "21.0.0";
      min_el = "1.6.0";
      max_el = "1.7.0";
    }
    {
      min_erl = "18.0.0";
      max_erl = "21.0.0";
      min_el = "1.5.0";
      max_el = "1.6.0";
    }
    {
      min_erl = "18.0.0";
      max_erl = "21.0.0";
      min_el = "1.4.5";
      max_el = "1.5.0";
    }
    {
      min_erl = "18.0.0";
      max_erl = "20.0.0";
      min_el = "1.4.0";
      max_el = "1.5.0";
    }
    {
      min_erl = "18.0.0";
      max_erl = "20.0.0";
      min_el = "1.3.0";
      max_el = "1.4.0";
    }
    {
      min_erl = "18.0.0";
      max_erl = "19.0.0";
      min_el = "1.2.0";
      max_el = "1.3.0";
    }
    {
      min_erl = "17.0.0";
      max_erl = "19.0.0";
      min_el = "1.1.0";
      max_el = "1.2.0";
    }
    {
      min_erl = "17.0.0";
      max_erl = "19.0.0";
      min_el = "1.0.5";
      max_el = "1.1.0";
    }
    {
      min_erl = "17.0.0";
      max_erl = "18.0.0";
      min_el = "1.0.0";
      max_el = "1.1.0";
    }
  ];

  normalizeOtp = version: let
    split = splitVersion version;
    padded =
      if (length split) < 3
      then split ++ [0]
      else split;
  in
    concatStringsSep "." (map toString padded);

  elixir' = normalizeElixir elixir;
  erlang' = normalizeOtp erlang;
  pred = bound:
    builtins.all (val: val) [
      (versionOlder erlang' bound.max_erl)
      (versionOlder elixir' bound.max_el)
      (versionAtLeast erlang' bound.min_erl)
      (versionAtLeast elixir' bound.min_el)
    ];
in
  builtins.isAttrs (findFirst pred false bounds)
