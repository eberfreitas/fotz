defmodule Fotz do
  def hello() do
    :world
  end

  def main(argv) do
    argv
    |> parse_opts()
    |> process()
  end

  def parse_opts(argv) do
    argv
    |> OptionParser.parse(
      strict: [
        help: :boolean,
        source: :string,
        dest: :string,
        format: :string,
        geokey: :string,
        language: :string,
        move: :boolean,
        config: :string
      ],
      aliases: [
        h: :help,
        s: :source,
        d: :dest,
        f: :format,
        k: :geokey,
        l: :language,
        m: :move,
        c: :config
      ]
    )
    |> elem(0)
    |> Enum.into(%{})
  end

  def process(%{source: _, dest: _, format: _} = opts) do
    opts
  end
end
