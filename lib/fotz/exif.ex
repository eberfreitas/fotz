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

  @exiftool "exiftool"

  @doc """
  Checks if exiftool is properly installed and can be called from the app.
  """
  @spec exiftool?() :: boolean
  def exiftool?() do
    try do
      {_, 0} = System.cmd(@exiftool, [])

      true
    rescue
      ErlangError -> false
    end
  end

  @doc """
  Receives a `file` param from which we extract exif data using `exiftool`. The
  `file` param must be a string of the full path of the file.
  """
  @spec exif(String.t()) :: :error | map
  def exif(file) do
    with {json, 0} <- System.cmd(@exiftool, ["-json", "-q", file]),
         {:ok, [data | _]} <- Jason.decode(json) do
      data
    else
      _ -> :error
    end
  end

  @doc """
  Receives a map with exif data and extracts the best date to use as the
  original file date. Look at the `@dates` module attribute to check what is
  inspected. Gets the oldest date from the available keys and returns a
  NaiveDateTime value.
  """
  @spec get_date(map) :: :error | NaiveDateTime.t()
  def get_date(exif) do
    dates =
      exif
      |> Enum.filter(fn i -> elem(i, 0) in @dates end)

    cond do
      Enum.count(dates) > 0 ->
        dates
        |> Enum.map(fn i -> make_valid_date(elem(i, 1)) end)
        |> Enum.reduce(NaiveDateTime.utc_now(), fn i, acc ->
          if i < acc, do: i, else: acc
        end)

      true ->
        :error
    end
  end

  @spec make_valid_date(String.t()) :: NaiveDateTime.t()
  defp make_valid_date(dirty_date) do
    [date, time] = String.split(dirty_date, " ")

    date =
      String.split(date, ":")
      |> Enum.join("-")

    {:ok, new_date} = NaiveDateTime.from_iso8601(date <> " " <> time)

    new_date
  end
end
