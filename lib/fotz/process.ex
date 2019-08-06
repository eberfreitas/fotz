defmodule Fotz.Process do
  alias Fotz.{Exif, Files, Format, GPS}

  def handle(file, format, dest, move, apikey, lang) do
    with {:ok, exif} <- Exif.exif(file),
         {:ok, date} <- Exif.get_date(exif),
         data = make_format(file, exif, date, apikey, lang),
         compiled = make_compiled_format(format, data),
         path = dest <> "/" <> compiled,
         parts = Path.split(path),
         dest_dir = build_dest_dir(parts),
         :ok <- make_dest_dir(dest_dir),
         :ok <- copy_or_move(move, file, path) do
      {file, path}
      |> IO.inspect()
    else
      _ -> exit(:error)
    end
  end

  defp copy_or_move(true, original, dest) do
    case File.rename(original, dest) do
      :ok -> :ok
      {:error, _} -> :error
    end
  end

  defp copy_or_move(false, original, dest) do
    case File.copy(original, dest) do
      {:ok, _} -> :ok
      {:error, _} -> :error
    end
  end

  defp build_dest_dir(parts) do
    (parts -- [List.last(parts)])
    |> Enum.join("/")
    |> String.replace("//", "/")
  end

  defp make_dest_dir(dest) do
    if !File.dir?(dest) do
      case File.mkdir_p(dest) do
        :ok -> :ok
        {:error, _} -> :error
      end
    else
      :ok
    end
  end

  defp make_compiled_format(format, data) do
    format
    |> String.replace("\\", "/")
    |> Format.compile(data)
    |> String.trim_leading("/")
    |> Files.clean_filename()
  end

  defp make_format(file, exif, date, apikey, lang) do
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

    %Format{
      year: date.year |> to_string(),
      month: date.month |> to_string() |> String.pad_leading(2, "0"),
      day: date.day |> to_string() |> String.pad_leading(2, "0"),
      hour: date.hour |> to_string() |> String.pad_leading(2, "0"),
      minute: date.minute |> to_string() |> String.pad_leading(2, "0"),
      second: date.second |> to_string() |> String.pad_leading(2, "0"),
      hash: hash,
      smallhash: String.slice(hash, 0..3),
      city:
        Map.get(gps, "city") ||
          Map.get(gps, "town") ||
          Map.get(gps, "municipality") ||
          Map.get(gps, "village") ||
          Map.get(gps, "hamlet") ||
          Map.get(gps, "locality") ||
          Map.get(gps, "croft"),
      state: Map.get(gps, "state"),
      country: Map.get(gps, "country"),
      camera: camera,
      ext: Files.file_extension(file),
      original: Files.file_name(file)
    }
  end
end
