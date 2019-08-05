defmodule Fotz.GPS do
  @moduledoc """
  Interacts with the Open Cage API to get info from GPS data.
  """

  import Mockery.Macro

  @typedoc """
  A signed float representing a coordinate (latitude or longitude) or a string
  representing a DMS coordinate.
  """
  @type coordinate :: String.t() | float

  @directions [s: -1, w: -1, n: 1, e: 1]

  @endpoint "https://api.opencagedata.com/geocode/v1/json"

  @doc """
  Receives a map with GPS info comming from the Exif module. Transmits GPS
  params to be executed by `Fotz.GPS.gps/4`.
  """
  @spec gps(map, String.t(), String.t()) :: :error | {:ok, map}
  def gps(%{"GPSPosition" => _} = exif, apikey, language) do
    gps(exif["GPSLatitude"], exif["GPSLongitude"], apikey, language)
  end

  def gps(exif, apikey, language) when is_map(exif), do: :error

  @doc """
  Receives the latitude, longitude and api key to get info from the Open Cage
  API. Optionaly you can pass a language param to get results in that language.
  It defaults to "native". See the Open Cage API
  [docs](https://opencagedata.com/api#language) to know more.
  """
  @spec gps(coordinate, coordinate, String.t(), String.t()) :: :error | {:ok, map}
  def gps(
        lat,
        lng,
        apikey,
        language
      )

  def gps(lat, lng, nil, language), do: :error

  def gps(lat, lng, apikey, language)
      when is_binary(lat)
      when is_binary(lng) do
    gps(dms_to_decimal(lat), dms_to_decimal(lng), apikey, language)
  end

  def gps(lat, lng, apikey, language) do
    language = language || "native"

    query = %{
      q: "#{lat},#{lng}",
      key: apikey,
      language: language
    }

    with {:ok, %{body: response, status_code: 200}} <- get(query),
         {:ok, %{"results" => [results | _]}} <- Jason.decode(response),
         data = results["components"] do
      {:ok, data}
    else
      _ -> :error
    end
  end

  @spec get(map) ::
          {:ok, HTTPoison.Response.t() | HTTPoison.AsyncResponse.t()}
          | {:error, HTTPoison.Error.t()}
  defp get(query) do
    mockable(HTTPoison).get(@endpoint <> "?" <> URI.encode_query(query), [], [])
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
