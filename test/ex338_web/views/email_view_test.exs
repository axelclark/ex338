defmodule Ex338Web.EmailViewTest do
  use Ex338Web.ConnCase, async: true

  alias Ex338Web.{EmailView}

  describe "display_player/1" do
    test "returns trimmed player name and abbrev" do
      player = %{
        player_name: "Name ",
        sports_league: %{
          abbrev: "CBB"
        }
      }

      assert EmailView.display_player(player) == "Name, CBB"
    end
  end
end
