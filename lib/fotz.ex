defmodule Fotz do
  alias Fotz.{Exif, Files, Format, GPS}

  def hello(), do: :world

  def main(argv) do
    argv
    |> parse_opts()
    |> process()
  end

  def parse_opts(argv) do
    Optimus.new!(
      name: "fotz",
      description: "Photos and videos organizer",
      version: "0.0.1",
      author: "Zyglab hello@zyglab.dev",
      about: "Organize your photos and videos based on EXIF metadata.",
      allow_unknown_args: false,
      parse_double_dash: true,
      flags: [
        move: [
          short: "-m",
          long: "--move",
          help: "Specifies if files should be moved insted of copied to the destination directory"
        ]
      ],
      options: [
        source: [
          value_name: "SOURCE_DIR",
          short: "-s",
          long: "--source",
          help: "Source directory",
          required: true,
          parser: fn source ->
            case Files.normalize_dir(source) do
              {:ok, dir} -> {:ok, dir}
              :error -> {:error, "Invalid source directory"}
            end
          end
        ],
        dest: [
          value_name: "DEST_DIR",
          short: "-d",
          long: "--dest",
          help: "Destination directory",
          required: true,
          parser: fn dest ->
            case Files.normalize_dir(dest) do
              {:ok, dir} -> {:ok, dir}
              :error -> {:error, "Invalid destination directory"}
            end
          end
        ],
        format: [
          value_name: "FORMAT",
          short: "-f",
          long: "--format",
          help: "The file name format this app should use to copy/move the files",
          required: true,
          parser: fn format ->
            case Format.valid?(format) do
              true -> {:ok, format}
              false -> {:error, "Format looks invalid"}
            end
          end
        ],
        apikey: [
          value_name: "API_KEY",
          short: "-k",
          long: "--apikey",
          help: "Your Open Cage API key. See https://opencagedata.com for more info",
          parser: :string,
          required: false
        ],
        lang: [
          value_name: "LANG",
          short: "-l",
          long: "--lang",
          help:
            "Open Cage API results language. See https://opencagedata.com/api#language for more info",
          parser: :string,
          required: false
        ]
      ]
    )
    |> Optimus.parse!(argv)
  end

  def process(args) do
    source = args.options.source
    dest = args.options.dest
    format = args.options.format
    move = args.flags.move
    apikey = args.options.apikey
    lang = args.options.lang

    files =
      case Files.files_from_dir(source) do
        {:ok, files} ->
          files

        :error ->
          IO.puts("Source directory does not contain files to handle.")
          System.halt(1)
      end

    files
    |> Enum.each(&handle(&1, dest, move, apikey, lang))
  end

  def handle(file, dest, move, apikey, lang) do
    with {:ok, exif} <- Exif.exif(file),
         {:ok, date} <- Exif.get_date(exif) do
      hash = Files.md5(file)

      gps =
        case GPS.gps(exif, apikey, lang) do
          {:ok, data} -> data
          :error -> %{}
        end

      camera =
        case Exif.camera(exif) do
          {:ok, cam} -> cam
          :error -> nil
        end

      format = %Format{
        year: date.year |> to_string(),
        month: date.month |> to_string() |> String.pad_leading(2, "0"),
        day: date.day |> to_string() |> String.pad_leading(2, "0"),
        hour: date.hour |> to_string() |> String.pad_leading(2, "0"),
        minutes: date.minute |> to_string() |> String.pad_leading(2, "0"),
        seconds: date.second |> to_string() |> String.pad_leading(2, "0"),
        hash: hash,
        smallhash: String.slice(hash, 0..3),
        city: gps |> Map.get("city"),
        state: gps |> Map.get("state"),
        country: gps |> Map.get("ISO_3166-1_alpha-2"),
        camera: camera,
        ext: Files.file_extension(file),
        original: Files.file_name(file)
      }

      format
      |> IO.inspect()
    else
      _ -> exit(:error)
    end
  end
end
