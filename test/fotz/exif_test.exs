defmodule Fotz.ExifTest do
  use ExUnit.Case

  alias Fotz.Exif

  doctest Fotz.Exif

  test "gets exif data" do
    exif = Exif.exif("./test/_samples/001.jpg")

    assert Enum.empty?(exif) == false
  end

  test "file date from exif" do
    exif = Exif.exif("./test/_samples/001.jpg")

    assert Exif.get_date(exif) == ~N[2019-08-01 08:54:39]
  end
end
