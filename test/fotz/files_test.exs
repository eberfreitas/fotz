defmodule Fotz.FilesTest do
  use ExUnit.Case

  alias Fotz.Files

  doctest Fotz.Files

  test "files from dir" do
    files =
      with {:ok, dir} <- Files.normalize_dir("./test/_samples"),
           files <- Files.files_from_dir(dir) do
        files
      end

    assert length(files) == 2
  end

  test "file extension" do
    assert Files.file_extension("test.jpg") == "jpg"
    assert Files.file_extension("./dir/test.PNG") == "png"
  end

  test "md5 file" do
    assert Files.md5("./test/_samples/001.jpg") == "6b059bae51c47433a7d6bf39697e50d8"
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
