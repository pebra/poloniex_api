use Mix.Config

config :poloniex_api,
  public_api_url: "https://poloniex.com/public",
  protected_api_url: "https://poloniex.com/tradingApi"

import_config "secrets.exs"
