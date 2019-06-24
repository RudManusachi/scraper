defmodule Scraper do
  @moduledoc """
  Documentation for Scraper.
  """

  alias Scraper.HTTP

  @doc """
  Fetches page assets and links
  """
  def fetch!(url, opt \\ []) do
    case fetch(url, opt) do
      {:ok, result} -> result
      {:error, error} -> raise error
    end
  end

  def fetch(url, opts \\ []) do
    with {:ok, body} <- HTTP.request(url, opts) do
      data_links = parse(body)

      result =
        for {k, paths} <- data_links, into: %{} do
          {k, paths_to_full_url(paths, url)}
        end

      {:ok, result}
    else
      error -> error
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
