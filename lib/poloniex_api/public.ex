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
  def ticker do
    fetch_ticker()
  end

  @spec ticker(binary, binary) :: map
  def ticker(source_ticker, target_ticker) do
    combined_ticker = String.upcase(source_ticker) <> "_" <> String.upcase(target_ticker)

    fetch_ticker()
    |> Enum.find(fn {ticker, _data} -> ticker == combined_ticker end)
  end

  def volume24, do: fetch_24_volume()

  def volume24(source_ticker, target_ticker) do
    combined_ticker = String.upcase(source_ticker) <> "_" <> String.upcase(target_ticker)

    fetch_24_volume()
    |> Enum.find(fn {ticker, _data} -> ticker == combined_ticker end)
  end

  def order_book, do: fetch_order_book("all")

  def order_book(source_ticker, target_ticker) do
    combined_ticker = String.upcase(source_ticker) <> "_" <> String.upcase(target_ticker)
    fetch_order_book(combined_ticker)
  end

  defp fetch_order_book(ticker) do
    HTTPoison.get!(
      api_url(),
      [{"Accept", "application/json"}],
      params: [{"command", "returnOrderBook"}, {"currencyPair", ticker}]
    )
    |> parse_response
  end

  defp fetch_ticker do
    HTTPoison.get!(
      api_url(),
      [{"Accept", "application/json"}],
      params: [{"command", "returnTicker"}],
      timeout: 10000,
      recv_timeout: 10000
    )
    |> parse_response
  end

  defp fetch_24_volume do
    HTTPoison.get!(
      api_url(),
      [{"Accept", "application/json"}],
      params: [{"command", "return24hVolume"}]
    )
    |> parse_response
  end

  defp parse_response(response) do
    response.body
    |> Poison.decode!()
  end

  defp api_url do
    Application.fetch_env!(:poloniex_api, :public_api_url)
  end
end
