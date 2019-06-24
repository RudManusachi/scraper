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
    with %HTTPoison.Response{body: body} <- HTTPoison.get!(url) do
      body
    end
  end

  defp parse(html) do
    assets =
      html
      |> Floki.find("img")
      |> Floki.attribute("src")

    links =
      html
      |> Floki.find("a")
      |> Floki.attribute("href")

    %{assets: assets, links: links}
  end
end
