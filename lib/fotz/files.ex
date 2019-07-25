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
  @spec files_from_dir(String.t()) :: [binary]
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
  Gets the md5 of a file's content.
  """
  @spec md5(String.t()) :: String.t()
  def md5(file) do
    {:ok, content} = File.read(file)

    :crypto.hash(:md5, content)
    |> Base.encode16()
    |> String.downcase()
  end
end
