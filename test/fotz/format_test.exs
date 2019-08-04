defmodule Fotz.FormatTest do
  use ExUnit.Case

  alias Fotz.Format

  doctest Fotz.Format

  test "compile" do
    data = %Format{ext: "jpg", original: "DSC0001"}

    assert Format.compile("{{original}}.{{ext}}", data) == "DSC0001.jpg"

    assert Format.compile("{{original}}{{#camera}} {{camera}}{{/camera}}.{{ext}}", data) ==
             "DSC0001.jpg"

    data = Map.put(data, :camera, "CANON")

    assert Format.compile("{{original}}{{#camera}} {{camera}}{{/camera}}.{{ext}}", data) ==
             "DSC0001 CANON.jpg"
  end

  test "is template valid?" do
    assert Format.valid?("{{nope}}.{{ext}}") == false
    assert Format.valid?("{{inexistent}} - {{inexistent}}.{{inexistent}}") == false
    assert Format.valid?("{{original}}.{{ext}}") == true
    assert Format.valid?("{{{original}}}.{{ext}}}") == false
  end
end
