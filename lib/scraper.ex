defmodule Scraper do
  require Logger

  @moduledoc """
  Documentation for Scraper.
  """

  @doc """
  Fetch page assets and links
  """
  def fetch!(url) do
    case fetch(url) do
      {:ok, result} -> result
      {:error, error} -> raise error
    end
  end

  def fetch(url) do
    with {:ok, body} <- request(url) do
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

  @max_retry_time 4
  @base_sleep_time 100
  @recv_timeout Application.get_env(:scraper, :request_timeout)

  defp request(url, retry_time \\ @max_retry_time, sleep_time \\ @base_sleep_time, err \\ nil)

  defp request(_url, retry_time, _sleep_time, err) when retry_time < 1 do
    {:error, err}
  end

  defp request(url, retry_time, sleep_time, _err) do
    with {:ok, %HTTPoison.Response{body: body}} <-
           HTTPoison.get(url, [], recv_timeout: @recv_timeout) do
      {:ok, body}
    else
      {:error, reason} ->
        Logger.warn("Request error #{url} \n #{inspect(reason)}")
        :timer.sleep((@max_retry_time - retry_time + 1) * @base_sleep_time)
        request(url, retry_time - 1, sleep_time, reason)
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
