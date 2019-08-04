defmodule Fotz.FilesTest do
  use ExUnit.Case

  alias Fotz.Files

  doctest Fotz.Files

  test "files from dir" do
    files =
      Files.normalize_dir("./test/_samples")
      |> Files.files_from_dir()

    assert length(files) == 2
  end

  test "file extension" do
    assert Files.file_extension("test.jpg") == "jpg"
    assert Files.file_extension("./dir/test.PNG") == "png"
  end

  test "md5 file" do
    assert Files.md5("./test/_samples/001.jpg") == "5f69d520fb4308355453b4060eb456fa"
  end

  test "file name" do
    assert Files.file_name("test.jpg") == "test"
    assert Files.file_name("directory/file.png") == "file"
    assert Files.file_name("../something/ELSE.PNG") == "ELSE"
  end

  test "normalize dir" do
    assert Files.normalize_dir("./test/_samples") != :error
    assert Files.normalize_dir("anything") == :error
  end
end
