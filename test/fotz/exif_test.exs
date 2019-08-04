defmodule Fotz.ExifTest do
  use ExUnit.Case

  alias Fotz.Exif

  doctest Fotz.Exif

  test "gets exif data" do
    {:ok, exif} = Exif.exif("./test/_samples/001.jpg")

    assert Enum.empty?(exif) == false
  end

  test "file date from exif" do
    {:ok, exif} = Exif.exif("./test/_samples/001.jpg")

    assert Exif.get_date(exif) == {:ok, ~N[2018-01-01 00:00:00]}
  end
end
