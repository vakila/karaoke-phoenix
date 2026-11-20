defmodule Karaoke.YouTube do
  @moduledoc """
  Unofficial YouTube search via the Innertube endpoint (no official API key required).
  """

  @endpoint "https://www.youtube.com/youtubei/v1/search"

  @doc """
  Searches YouTube for `query` and returns up to `limit` results.

  Each result is a map with `:id`, `:title`, `:channel`, and `:thumbnail`.
  """
  def search(query, limit \\ 3) do
    url =
      case System.get_env("YOUTUBE_INNERTUBE_KEY") do
        nil -> @endpoint
        key -> @endpoint <> "?key=" <> URI.encode_www_form(key)
      end

    body = %{
      "context" => %{"client" => %{"clientName" => "WEB", "clientVersion" => "2.20240101.00.00"}},
      "query" => query
    }

    case Req.post(url,
           json: body,
           headers: [{"user-agent", "Mozilla/5.0"}, {"accept-language", "en"}]
         ) do
      {:ok, %{status: 200, body: %{"contents" => _} = data}} ->
        {:ok, parse(data, limit)}

      {:ok, %{status: status}} ->
        {:error, {:http_status, status}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp parse(data, limit) do
    items =
      data
      |> get_in([
        "contents",
        "twoColumnSearchResultsRenderer",
        "primaryContents",
        "sectionListRenderer",
        "contents"
      ])
      |> case do
        [first | _] -> get_in(first, ["itemSectionRenderer", "contents"]) || []
        _ -> []
      end

    items
    |> Enum.flat_map(fn
      %{"videoRenderer" => vr} -> [build(vr)]
      _ -> []
    end)
    |> Enum.take(limit)
  end

  defp build(vr) do
    %{
      id: vr["videoId"],
      title: text(vr["title"]),
      channel: text(vr["ownerText"]),
      thumbnail: thumbnail(vr["thumbnail"], vr["videoId"])
    }
  end

  defp text(%{"runs" => runs}), do: Enum.map_join(runs, "", & &1["text"])
  defp text(_), do: nil

  defp thumbnail(%{"thumbnails" => [t | _]}, _), do: t["url"]
  defp thumbnail(_, id), do: "https://i.ytimg.com/vi/#{id}/hqdefault.jpg"

  @doc "Checks whether YouTube allows embedding this video on third-party sites."
  def embeddable?(id) when is_binary(id) do
    if valid_id?(id) do
      url = "https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=#{id}&format=json"

      case Req.get(url) do
        {:ok, %{status: 200}} -> true
        _ -> false
      end
    else
      false
    end
  end

  def embeddable?(_), do: false

  @doc "Validates a YouTube video id."
  def valid_id?(id) when is_binary(id) do
    Regex.match?(~r/^[A-Za-z0-9_-]{11}$/, id)
  end

  def valid_id?(_), do: false
end
