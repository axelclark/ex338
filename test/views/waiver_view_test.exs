defmodule Ex338.WaiverViewTest do
  use Ex338.ConnCase, async: true
  alias Ex338.{WaiverView}

  describe "sort_most_recent/1" do
    test "returns struct sorted by most recent first" do
      waivers = [
        %{fantasy_team: "a",
          process_at: Ecto.DateTime.cast!(
            %{day: 1, hour: 14, min: 0, month: 4, sec: 0, year: 2010}
          )},
        %{fantasy_team: "c",
          process_at: Ecto.DateTime.cast!(
            %{day: 3, hour: 14, min: 0, month: 4, sec: 0, year: 2010}
          )},
        %{fantasy_team: "b",
          process_at: Ecto.DateTime.cast!(
            %{day: 2, hour: 14, min: 0, month: 4, sec: 0, year: 2010}
          )},
      ]

      result = WaiverView.sort_most_recent(waivers)

      assert Enum.map(result, &(&1.fantasy_team)) == ["c", "b", "a"]
    end
  end
end
