defmodule PoloniexApi.Public do
  @moduledoc """
  # Implementation of Poloniex' Public Api
  ## Currently Implemented Methods
    + returnCurrency
    + return24hVolume
    + returnOrderBook
    + returnTradeHistory
    + returnChartData
    + returnCurrencies
    + returnLoanOrders
  """

  @default_timestamp_offset -600

  def currency do
    fetch_currency()
  end

  @spec currency(binary, binary) :: map
  def currency(source_currency, target_currency) do
    combined_currency = combine_currencies(source_currency, target_currency)

    case fetch_currency() do
      {:ok, currencies} -> find_currency(currencies, combined_currency)
      error -> error
    end
  end

  def volume24, do: fetch_24_volume()

  def volume24(source_currency, target_currency) do
    combined_currency = combine_currencies(source_currency, target_currency)

    case fetch_24_volume() do
      {:ok, currencies} -> find_currency(currencies, combined_currency)
      error -> error
    end
  end

  def order_book, do: fetch_order_book("all")

  def order_book(source_currency, target_currency) do
    combined_currency = combine_currencies(source_currency, target_currency)

    fetch_order_book(combined_currency)
  end

  def trade_history(source_currency, target_currency) do
    combined_currency = combine_currencies(source_currency, target_currency)
    start_timestamp = unix_timestamp(@default_timestamp_offset)
    end_timestamp = unix_timestamp()

    fetch_trade_history(combined_currency, start_timestamp, end_timestamp)
  end

  def trade_history(source_currency, target_currency, start_timestamp, end_timestamp) do
    combined_currency = combine_currencies(source_currency, target_currency)
    fetch_trade_history(combined_currency, start_timestamp, end_timestamp)
  end

  def chart_data(source_currency, target_currency, period \\ 300)
      when period in [300, 900, 1800, 7200, 14400, 86400] do
    combined_currency = combine_currencies(source_currency, target_currency)
    start_timestamp = unix_timestamp(@default_timestamp_offset)
    end_timestamp = unix_timestamp()

    fetch_chart_data(combined_currency, start_timestamp, end_timestamp, period)
  end

  def chart_data(source_currency, target_currency, start_timestamp, end_timestamp, period \\ 300)
      when period in [300, 900, 1800, 7200, 14400, 86400] do
    combined_currency = combine_currencies(source_currency, target_currency)

    fetch_chart_data(combined_currency, start_timestamp, end_timestamp, period)
  end

  def currencies do
    fetch_currencies()
  end

  def currencies(currency) do
    case fetch_currencies() do
      {:ok, currencies} -> find_currency(currencies, currency)
      error -> error
    end
  end

  def loan_orders(currency) do
    get([{"command", "returnLoanOrders"}, {"currency", currency}])
  end

  defp find_currency(collection, currency) do
    case collection |> Enum.find(fn {curr, _data} -> curr == currency end) do
      nil -> {:error, "Currency not found"}
      success -> {:ok, success}
    end
  end

  defp fetch_currencies do
    get([{"command", "returnCurrencies"}])
  end

  defp fetch_chart_data(currency, start_timestamp, end_timestamp, period) do
    get([
      {"command", "returnChartData"},
      {"currencyPair", currency},
      {"start", start_timestamp},
      {"end", end_timestamp},
      {"period", period}
    ])
  end

  defp fetch_trade_history(currency, start_timestamp, end_timestamp) do
    get([
      {"command", "returnTradeHistory"},
      {"currencyPair", currency},
      {"start", start_timestamp},
      {"end", end_timestamp}
    ])
  end

  defp fetch_order_book(currency) do
    get([{"command", "returnOrderBook"}, {"currencyPair", currency}])
  end

  defp fetch_currency do
    get([{"command", "returnCurrency"}])
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

  defp combine_currencies(source_currency, target_currency) do
    String.upcase(source_currency) <> "_" <> String.upcase(target_currency)
  end
end
