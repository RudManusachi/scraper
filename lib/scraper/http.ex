defmodule Scraper.HTTP do
  @moduledoc false

  require Logger

  @max_retry_time 4
  @base_sleep_time 100

  def request(url, opts \\ []) when is_list(opts) do
    do_request(url, @max_retry_time, @base_sleep_time, nil, opts)
  end

  defp do_request(_url, 0, _sleep_time, err, _opts) do
    {:error, err}
  end

  defp do_request(url, retry_time, sleep_time, _err, opts) do
    with {:ok, %HTTPoison.Response{body: body}} <-
           HTTPoison.get(url, [], opts) do
      {:ok, body}
    else
      {:error, reason} ->
        Logger.warn("Request error #{url} \n #{inspect(reason)}")
        :timer.sleep((@max_retry_time - retry_time + 1) * @base_sleep_time)
        do_request(url, retry_time - 1, sleep_time, reason, opts)
    end
  end
end
