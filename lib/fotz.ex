defmodule Fotz do
  alias Fotz.{Files, Format}

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
          parser: :string,
          required: true
        ],
        dest: [
          value_name: "DEST_DIR",
          short: "-d",
          long: "--dest",
          help: "Destination directory",
          parser: :string,
          required: true
        ],
        format: [
          value_name: "FORMAT",
          short: "-f",
          long: "--format",
          help: "The file name format this app should use to copy/move the files",
          parser: :string,
          required: true
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

    source =
      case Files.normalize_dir(source) do
        :error ->
          IO.puts("Source directory is invalid.")
          System.halt(1)

        s ->
          s
      end

    dest =
      case Files.normalize_dir(dest) do
        :error ->
          IO.puts("Destination directory is invalid.")
          System.halt(1)

        s ->
          s
      end

    if !Format.valid?(format) do
      IO.puts("Format looks invalid.")
      System.halt(1)
    end

    files = Files.files_from_dir(source)

    if files == [] do
      IO.puts("Source directory does not contain files to handle.")
      System.halt(1)
    end
  end
end
