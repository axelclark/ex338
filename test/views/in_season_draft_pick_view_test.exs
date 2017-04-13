defmodule Ex338.InSeasonDraftPickViewTest do
  use Ex338.ConnCase, async: true
  alias Ex338.{InSeasonDraftPickView, FantasyPlayer}

  describe "format_players_as_options/1" do
    test "returns a list of tuples with player names and ids" do
      players = [
        %FantasyPlayer{id: 1, player_name: "A"},
        %FantasyPlayer{id: 2, player_name: "B"},
      ]

      result = InSeasonDraftPickView.format_players_as_options(players)

      assert result == [{"A", 1}, {"B", 2}]
    end
  end

end