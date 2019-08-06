defmodule Fotz.ExifTest do
  use ExUnit.Case

  alias Fotz.Exif

  doctest Fotz.Exif

  test "is exif available?" do
    assert Exif.exiftool?() == true
  end

  test "gets exif data" do
    {:ok, exif} = Exif.exif("./test/_samples/001.jpg")

    assert Enum.empty?(exif) == false
  end

  test "file date from exif" do
    {:ok, exif} = Exif.exif("./test/_samples/001.jpg")

    assert Exif.get_date(exif) == {:ok, ~N[2018-01-01 00:00:00]}

    {:ok, exif} = Exif.exif("./test/_samples/subdir/002.jpg")

    assert Exif.get_date(exif) == {:ok, ~N[2002-01-01 12:00:00]}

    assert Exif.get_date(%{"NoDate" => true}) == :error
  end

  test "get camera" do
    assert Exif.camera(%{"Model" => "CANON"}) == {:ok, "CANON"}
    assert Exif.camera(%{"Model" => "CANON", "Make" => "367"}) == {:ok, "CANON (367)"}
    assert Exif.camera(%{}) == :error
  end
end
