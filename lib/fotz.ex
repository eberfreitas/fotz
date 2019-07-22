defmodule Fotz do
  @extensions [
    "jpg",
    "jpeg",
    "mov",
    "mp4",
    "mpg",
    "avi"
  ]

  @maps_endpoint "https://api.opencagedata.com/geocode/v1/json"

  def main(argv) do
    argv
    |> parse_opts()
    |> process()
  end

  def parse_opts(argv) do
    argv
    |> OptionParser.parse(
      strict: [
        help: :boolean
        source: :string,
        dest: :string,
        geokey: :string,
        language: :string,
        move: :boolean,
        config: :string
      ],
      aliases: [
        h: :help,
        s: :source,
        d: :dest,
        k: :geokey,
        l: :language,
        m: :move,
        c: :config
      ]
    )
    |> elem(0)
    |> Enum.into(%{})
  end

  def process(%{source: _, dest: _} = opts) do
    opts
  end

  def process(_) do
    exit(:normal)
  end

  def files_from_dir(dir) do
    dir =
      dir
      |> String.trim()
      |> String.replace("\\", "/")
      |> Path.expand()
      |> String.trim_trailing("/")

    joined_extensions = Enum.join(@extensions, ",")
    joined_up_extensions = String.upcase(joined_extensions)

    (dir <> "/**/*.{#{joined_extensions},#{joined_up_extensions}}")
    |> Path.wildcard()
  end

  def file_extension(file) do
    file
    |> Path.extname()
    |> String.trim_leading(".")
    |> String.downcase()
  end

  def exif(file) do
    {json, 0} = System.cmd("exiftool", ["-json", "-q", file])
    {:ok, [data]} = Jason.decode(json)

    data
  end

  def dms_to_degrees(dms) do
    regex = ~r{(?<deg>\d+) deg (?<min>\d+)' (?<sec>\d+\.\d+)" (?<dir>[S|s|W|w|N|n|E|e])}
    capture = Regex.named_captures(regex, dms)
    directions = [s: -1, w: -1, n: 1, e: 1]
    degrees = String.to_integer(capture["deg"])
    minutes = String.to_integer(capture["min"])
    seconds = String.to_float(capture["sec"])

    direction =
      capture["dir"]
      |> String.downcase()
      |> String.to_atom()

    {:ok, direction} = Keyword.fetch(directions, direction)

    ((degrees + minutes / 60 + seconds / 3600) * direction)
    |> Float.round(6)
  end

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

  def md5(file) do
    {:ok, content} = File.read(file)

    :crypto.hash(:md5, content)
    |> Base.encode16()
    |> String.downcase()
  end
end
