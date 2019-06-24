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

    img_srcs = [
      "#{url}/img1",
      "#{url}/img2",
      "#{url}/img3"
    ]

    a_hrefs = [
      "#{url}/a1",
      "#{url}/a2",
      "#{url}/a3"
    ]

    body =
      Enum.reduce(img_srcs, "", fn src, body ->
        body <> "<img src=\"#{src}\" \/>"
      end)

    body =
      Enum.reduce(a_hrefs, body, fn href, body ->
        body <> "<a href=\"#{href}\">Link</a>"
      end)

    body = """
    <div>
      #{body}
    </div>
    """

    use_bypass(bypass, body)

    assert %{assets: assets, links: links} = Scraper.fetch(endpoint_url(bypass.port))
    assert links == a_hrefs
    assert assets == img_srcs
  end

  defp endpoint_url(port), do: "http://localhost:#{port}"
end
