# PoloniexApi - WORK IN PROGRESS

## Current State

+ Public API implemented

+ *TODO* implement trading api


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `poloniex_api` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:poloniex_api, "~> 0.1.0"}
  ]
end
```

### Config

To start making calls to the trading api you need a secrets file at `config/secrets.exs` and configure your
api and secret key like this:

```
# example config/secret.exs
use Mix.Config

config :poloniex_api,
  api_key: "YOUR_API_KEY",
  api_secret: "YOUR_API_SECRET"
```



Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/poloniex_api](https://hexdocs.pm/poloniex_api).
