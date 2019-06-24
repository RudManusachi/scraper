defmodule Scraper.HTTP do
  @moduledoc false

  require Logger

  @max_retry_time 4
  @base_sleep_time 100
  @recv_timeout Application.get_env(:scraper, :request_timeout)

  def request(url, retry_time \\ @max_retry_time, sleep_time \\ @base_sleep_time, err \\ nil)

  def request(_url, retry_time, _sleep_time, err) when retry_time < 1 do
    {:error, err}
  end

  def request(url, retry_time, sleep_time, _err) do
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
end
