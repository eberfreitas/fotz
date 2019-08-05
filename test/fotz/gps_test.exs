defmodule Fotz.GPSTest do
  use ExUnit.Case

  import Mockery

  alias Fotz.GPS

  doctest Fotz.GPS

  test "gps info" do
    mock(HTTPoison, [get: 3], fn _, _, _ ->
      {:ok, response} = File.read("./test/_samples/api_response.json")

      {:ok, %{body: response, status_code: 200}}
    end)

    {:ok, gps} = GPS.gps("51 deg 29' 25.8\" N", "0 deg 01' 02.7\" W", "dummy", nil)

    assert Enum.empty?(gps) == false
  end

  test "trying to get gps without api key" do
    assert GPS.gps("dummy", "dummy", nil, "dummy") == :error
  end

  test "dms to decimal" do
    assert GPS.dms_to_decimal("51 deg 29' 25.8\" N") == 51.4905
    assert GPS.dms_to_decimal("0 deg 01' 02.7\" W") == -0.0174167
  end
end
