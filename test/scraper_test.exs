defmodule ScraperTest do
  use ExUnit.Case, async: true
  doctest Scraper

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  def use_bypass(bypass, body \\ nil) do
    Bypass.expect(bypass, fn conn ->
      Plug.Conn.resp(conn, 200, body)
    end)
  end

  test "fetch/1 returns %Map with lists :assets and :links", %{bypass: bypass} do
    use_bypass(bypass, "")
    assert %{assets: assets, links: links} = Scraper.fetch(endpoint_url(bypass.port))
    assert is_list(assets)
    assert is_list(links)
  end

  test "happy path :assets and :links are the lists of urls present in the <img> and <a> tags respectively",
       %{bypass: bypass} do
    url = endpoint_url(bypass.port)

    img_srcs = ["#{url}/img1", "#{url}/img2", "#{url}/img3"]
    a_hrefs = ["#{url}/a1", "#{url}/a2", "#{url}/a3"]

    body = generate_simple_body(img_srcs, a_hrefs)
    use_bypass(bypass, body)

    assert %{assets: assets, links: links} = Scraper.fetch(url)
    assert links == a_hrefs
    assert assets == img_srcs
  end

  test "fetch/1 returns full url despite the urls in file", %{bypass: bypass} do
    img_srcs = ["img1", "img2", "img3"]
    a_hrefs = ["a1", "a2", "a3"]

    body = generate_simple_body(img_srcs, a_hrefs)
    use_bypass(bypass, body)

    url = endpoint_url(bypass.port)
    assert %{assets: assets, links: links} = Scraper.fetch(url)
    assert links == Enum.map(a_hrefs, fn href -> "#{url}/#{href}" end)
    assert assets == Enum.map(img_srcs, fn src -> "#{url}/#{src}" end)
  end

  test "fetch/1 handles anchors and js-links properly", %{bypass: bypass} do
    url = endpoint_url(bypass.port)
    a_hrefs = ["#{url}/a1", "#a2", "javascript:a3()"]

    body = generate_simple_body([], a_hrefs)
    use_bypass(bypass, body)

    assert %{assets: [], links: links} = Scraper.fetch(url)
    assert links == ["#{url}/a1", "#{url}/#a2"]
  end

  defp generate_simple_body(img_srcs, a_hrefs) do
    body =
      Enum.reduce(img_srcs, "", fn src, body ->
        body <> "<img src=\"#{src}\" \/>"
      end)

    body =
      Enum.reduce(a_hrefs, body, fn href, body ->
        body <> "<a href=\"#{href}\">Link</a>"
      end)

    """
    <div>
      #{body}
    </div>
    """
  end

  defp endpoint_url(port), do: "http://localhost:#{port}"
end
