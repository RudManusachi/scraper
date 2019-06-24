defmodule ScraperTest do
  use ExUnit.Case
  doctest Scraper

  @url "https://theguardian.com"

  test "fetch/1 returns %Map with lists :assets and :links" do
    assert %{assets: assets, links: links} = Scraper.fetch(@url)
    assert is_list(assets)
    assert is_list(links)
  end
end
