defmodule Ex338.CommishEmailViewTest do
  use Ex338.ConnCase, async: true
  alias Ex338.{CommishEmailView}

  describe "format_leagues_for_select/1" do
    test "formats leagues for multiple select in form" do
      leagues = [
        %{fantasy_league_name: "Div A", id: 1},
        %{fantasy_league_name: "Div B", id: 2}
      ]

      results = CommishEmailView.format_leagues_for_select(leagues)

      assert results == ["Div A": 1, "Div B": 2]
    end
  end
end
