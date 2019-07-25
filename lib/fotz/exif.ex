defmodule Fotz.Exif do
  @moduledoc """
  A set of tools to inspect exif data from a file. Uses `exiftool` to perform
  inspections.
  """

  @dates [
    "DateTime",
    "DateTimeOriginal",
    "FileCreateDate",
    "FileModifyDate"
  ]

  @doc """
  Receives a `file` param from which we extract exif data using `exiftool`. The
  `file` param must be a string of the full path of the file.
  """
  @spec exif(String.t) :: map
  def exif(file) do
    {json, 0} = System.cmd("exiftool", ["-json", "-q", file])
    {:ok, [data]} = Jason.decode(json)

    data
  end

  @doc """
  Receives a map with exif data and extracts the best date to use as the
  original file date. Look at the `@dates` module attribute to check what is
  inpected. Gets the oldest date from the available keys and returns a
  NaiveDateTime value.
  """
  @spec get_date(map) :: NaiveDateTime.t
  def get_date(exif) do
    exif
    |> Enum.filter(fn i -> elem(i, 0) in @dates end)
    |> Enum.map(fn i -> make_valid_date(elem(i, 1)) end)
    |> Enum.reduce(NaiveDateTime.utc_now(), fn i, acc ->
      if i < acc, do: i, else: acc
    end)
  end

  @spec make_valid_date(String.t) :: NaiveDateTime.t
  defp make_valid_date(dirty_date) do
    [date, time] = String.split(dirty_date, " ")

    date =
      String.split(date, ":")
      |> Enum.join("-")

    {:ok, new_date} = NaiveDateTime.from_iso8601(date <> " " <> time)

    new_date
  end
end