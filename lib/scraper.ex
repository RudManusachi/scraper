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
      {k, paths_to_full_url(links, url)}
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

  defp paths_to_full_url(paths, url) do
    paths
    |> Enum.filter(fn
      "javascript:" <> _script -> false
      _link -> true
    end)
    |> Enum.map(&URI.merge("#{url}/", &1))
    |> Enum.map(&URI.to_string/1)
  end
end
