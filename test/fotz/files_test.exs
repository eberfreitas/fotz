defmodule Fotz.FilesTest do
  use ExUnit.Case

  alias Fotz.Files

  doctest Fotz.Files

  test "files from dir" do
    files = Files.files_from_dir("./test/_samples")

    assert length(files) == 2
  end
end
