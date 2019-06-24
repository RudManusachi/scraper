defmodule Scraper do
  @moduledoc """
  Documentation for Scraper.
  """

  @doc """
  Fetch page assets and links
  """

  def fetch(url) do
    url
    |> request()
    |> parse()
  end

  defp request(url) do
    ""
  end

  defp parse(html) do
    %{assets: [], links: []}
  end
end
