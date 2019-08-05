defmodule Fotz.Files do
  @moduledoc """
  General file and directiory handling functions.
  """

  @extensions [
    "jpg",
    "jpeg",
    "mov",
    "mp4",
    "mpg",
    "avi"
  ]

  @doc """
  Receives a `dir` param with a string pointing to a path with images and videos
  files. Tries to find every supported file inside that path, including
  subfolders. Returns a list of all files.
  """
  @spec files_from_dir(String.t()) :: :error | {:ok, [binary]}
  def files_from_dir(dir) do
    joined_extensions = Enum.join(@extensions, ",")
    joined_up_extensions = String.upcase(joined_extensions)
    final_path = dir <> "/**/*.{#{joined_extensions},#{joined_up_extensions}}"

    case files = Path.wildcard(final_path) do
      [_ | _] -> {:ok, files}
      [] -> :error
    end
  end

  @doc """
  Returns a normalized file extension like `jpg`.
  """
  @spec file_extension(String.t()) :: String.t()
  def file_extension(file) do
    file
    |> Path.extname()
    |> String.trim_leading(".")
    |> String.downcase()
  end

  @doc """
  Returns the file name without the extension.
  """
  @spec file_name(String.t()) :: String.t()
  def file_name(file) do
    file
    |> Path.basename()
    |> String.replace(Path.extname(file), "")
  end

  @doc """
  Gets the md5 of a file's content.
  """
  @spec md5(String.t()) :: String.t()
  def md5(file) do
    {:ok, content} = File.read(file)

    :crypto.hash(:md5, content)
    |> Base.encode16()
    |> String.downcase()
  end

  @doc """
  Receives a directory path and normalizes it for futher inspection and
  manipulation.
  """
  @spec normalize_dir(String.t()) :: :error | {:ok, String.t()}
  def normalize_dir(dir) do
    normalized =
      dir
      |> String.trim()
      |> String.replace("\\", "/")
      |> Path.expand()
      |> String.trim_trailing("/")

    case File.dir?(normalized) do
      true -> {:ok, normalized}
      _ -> :error
    end
  end
end
