defmodule Fotz.FilesTest do
  use ExUnit.Case

  alias Fotz.Files

  doctest Fotz.Files

  test "files from dir" do
    files = Files.files_from_dir("./test/_samples")

    assert length(files) == 2
  end

  test "file extension" do
    assert Files.file_extension("test.jpg") == "jpg"
    assert Files.file_extension("./dir/test.PNG") == "png"
  end

  test "md5 file" do
    assert Files.md5("./test/_samples/001.jpg") == "5f69d520fb4308355453b4060eb456fa"
  end
end
