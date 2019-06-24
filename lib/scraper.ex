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
    |> Enum.map(fn {k, links} ->
      full_links =
        links
        |> Enum.map(&URI.merge(url, &1))
        |> Enum.map(&URI.to_string/1)

      {k, full_links}
    end)
    |> Enum.into(%{})
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

    [assets: assets, links: links]
  end
end
