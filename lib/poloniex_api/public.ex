defmodule PoloniexApi.Public do
  @moduledoc """
  # Implementation of Poloniex' Public Api
  ## Currently Implemented Methods
    + returnTicker
    + return24hVolume
    + returnOrderBook
    + returnTradeHistory
    + returnChartData
    + returnCurrencies
    + returnLoanOrders
  """

  @default_timestamp_offset -600

  def ticker do
    fetch_ticker()
  end

  @spec ticker(binary, binary) :: map
  def ticker(source_ticker, target_ticker) do
    combined_ticker = combine_tickers(source_ticker, target_ticker)

    case fetch_ticker() do
      {:ok, currencies} -> find_ticker(currencies, combined_ticker)
      error -> error
    end
  end

  def volume24, do: fetch_24_volume()

  def volume24(source_ticker, target_ticker) do
    combined_ticker = combine_tickers(source_ticker, target_ticker)

    fetch_24_volume()
    |> Enum.find(fn {ticker, _data} -> ticker == combined_ticker end)
  end

  def order_book, do: fetch_order_book("all")

  def order_book(source_ticker, target_ticker) do
    combined_ticker = combine_tickers(source_ticker, target_ticker)

    fetch_order_book(combined_ticker)
  end

  def trade_history(source_ticker, target_ticker) do
    combined_ticker = combine_tickers(source_ticker, target_ticker)
    start_timestamp = unix_timestamp(@default_timestamp_offset)
    end_timestamp = unix_timestamp()

    fetch_trade_history(combined_ticker, start_timestamp, end_timestamp)
  end

  def trade_history(source_ticker, target_ticker, start_timestamp, end_timestamp) do
    combined_ticker = combine_tickers(source_ticker, target_ticker)
    fetch_trade_history(combined_ticker, start_timestamp, end_timestamp)
  end

  def chart_data(source_ticker, target_ticker, period \\ 300)
      when period in [300, 900, 1800, 7200, 14400, 86400] do
    combined_ticker = combine_tickers(source_ticker, target_ticker)
    start_timestamp = unix_timestamp(@default_timestamp_offset)
    end_timestamp = unix_timestamp()

    fetch_chart_data(combined_ticker, start_timestamp, end_timestamp, period)
  end

  def chart_data(source_ticker, target_ticker, start_timestamp, end_timestamp, period \\ 300)
      when period in [300, 900, 1800, 7200, 14400, 86400] do
    combined_ticker = combine_tickers(source_ticker, target_ticker)

    fetch_chart_data(combined_ticker, start_timestamp, end_timestamp, period)
  end

  def currencies do
    fetch_currencies()
  end

  def currencies(ticker) do
    case fetch_currencies() do
      {:ok, currencies} -> currencies |> Enum.find(fn {curr, _data} -> curr == ticker end)
      error -> error
    end
  end

  defp find_ticker(collection, ticker) do
    case collection |> Enum.find(fn {curr, _data} -> curr == ticker end) do
      nil -> {:error, "Currency not found"}
      success -> {:ok, success}
    end
  end

  defp fetch_currencies do
    get([{"command", "returnCurrencies"}])
  end

  defp fetch_chart_data(ticker, start_timestamp, end_timestamp, period) do
    get([
      {"command", "returnChartData"},
      {"currencyPair", ticker},
      {"start", start_timestamp},
      {"end", end_timestamp},
      {"period", period}
    ])
  end

  defp fetch_trade_history(ticker, start_timestamp, end_timestamp) do
    get([
      {"command", "returnTradeHistory"},
      {"currencyPair", ticker},
      {"start", start_timestamp},
      {"end", end_timestamp}
    ])
  end

  defp fetch_order_book(ticker) do
    get([{"command", "returnOrderBook"}, {"currencyPair", ticker}])
  end

  defp fetch_ticker do
    get([{"command", "returnTicker"}])
  end

  defp fetch_24_volume do
    get([{"command", "return24hVolume"}])
  end

  defp get(params, headers \\ [{"Accept", "application/json"}]) do
    case HTTPoison.get(api_url(), headers, params: params) do
      {:ok, resp} -> parse_response(resp.body)
      {:error, _} = err -> err
    end
  end

  defp parse_response(response) do
    case response |> Poison.decode() do
      {:ok, %{"error" => _} = msg} -> {:error, msg}
      msg -> msg
    end
  end

  defp api_url do
    Application.fetch_env!(:poloniex_api, :public_api_url)
  end

  def unix_timestamp(offset \\ 0) do
    (:erlang.system_time() / 1.0e9 + offset)
    |> round
  end

  defp combine_tickers(source_ticker, target_ticker) do
    String.upcase(source_ticker) <> "_" <> String.upcase(target_ticker)
  end
end
