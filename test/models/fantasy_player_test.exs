defmodule Ex338.FantasyPlayerTest do
  @moduledoc false

  use Ex338.ModelCase, async: true

  alias Ex338.FantasyPlayer

  @valid_attrs %{player_name: "some content", sports_league_id: 12}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = FantasyPlayer.changeset(%FantasyPlayer{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = FantasyPlayer.changeset(%FantasyPlayer{}, @invalid_attrs)
    refute changeset.valid?
  end

  describe "format_players_for_select/1" do
    test "returns name, abbrev, and id in a tuple" do
      players = [
        %{id: 124, league_abbrev: "CBB", player_name: "Notre Dame"},
        %{id: 127, league_abbrev: "CBB", player_name: "Ohio State "}
      ]

      result = FantasyPlayer.format_players_for_select(players)

      assert result == [{"Notre Dame, CBB", 124}, {"Ohio State , CBB", 127}]
    end
  end
end
