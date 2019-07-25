defmodule Fotz.GPS do
  @moduledoc """
  Interacts with the Open Cage API to get info from GPS data.
  """

  @maps_endpoint "https://api.opencagedata.com/geocode/v1/json"

  @directions [s: -1, w: -1, n: 1, e: 1]

  @doc """
  Receives the latitude, longitude and api key to get info from the Open Cage
  API. Optionaly you can pass a language param to get results in that language.
  It defaults to "native". See the Open Cage API
  [docs](https://opencagedata.com/api#language) to know more.
  """
  @spec gps(float, float, String.t(), String.t() | nil) :: map
  def gps(lat, lng, api_key, language \\ nil) do
    language = language || "native"

    query = %{
      q: "#{lat},#{lng}",
      key: api_key,
      language: language
    }

    url = @maps_endpoint <> "?" <> URI.encode_query(query)

    {:ok, %{body: response, status_code: 200}} = HTTPoison.get(url)
    {:ok, %{"results" => results}} = Jason.decode(response)

    List.first(results)["components"]
  end

  @doc """
  GPS info comming from exif data is formatted as DMS (degrees minutes seconds).
  The Open Cage API expects decimal degrees. This function converts a DMS
  coordinate to its decimal degrees representation.
  """
  @spec dms_to_decimal(String.t()) :: float
  def dms_to_decimal(dms) do
    regex = ~r{(?<deg>\d+) deg (?<min>\d+)' (?<sec>\d+\.\d+)" (?<dir>[S|s|W|w|N|n|E|e])}
    capture = Regex.named_captures(regex, dms)
    degrees = String.to_integer(capture["deg"])
    minutes = String.to_integer(capture["min"])
    seconds = String.to_float(capture["sec"])

    direction =
      capture["dir"]
      |> String.downcase()
      |> String.to_atom()

    {:ok, direction} = Keyword.fetch(@directions, direction)

    ((degrees + minutes / 60 + seconds / 3600) * direction)
    |> Float.round(7)
  end
end
