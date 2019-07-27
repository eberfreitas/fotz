defmodule Fotz.GPSTest do
  use ExUnit.Case

  alias Fotz.GPS

  doctest Fotz.GPS

  test "dms to decimal" do
    assert GPS.dms_to_decimal("51 deg 29' 25.8\" N") == 51.4905
    assert GPS.dms_to_decimal("0 deg 01' 02.7\" W") == -0.0174167
  end
end
