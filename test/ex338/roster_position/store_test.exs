defmodule Ex338.RosterPosition.StoreTest do
  use Ex338.DataCase
  alias Ex338.{RosterPosition.Store}

  describe "all_positions/0" do
    test "returns all positions" do
      sport_b = insert(:sports_league, abbrev: "b")
      sport_c = insert(:sports_league, abbrev: "c")
      sport_a = insert(:sports_league, abbrev: "a")
      sport_z = insert(:sports_league, abbrev: "z")

      league = insert(:fantasy_league)

      insert(:league_sport, fantasy_league: league, sports_league: sport_a)
      insert(:league_sport, fantasy_league: league, sports_league: sport_b)
      insert(:league_sport, fantasy_league: league, sports_league: sport_c)

      result = Store.all_positions()

      assert Enum.count(result) == 11
      assert Enum.any?(result, &(&1 == sport_a.abbrev))
      assert Enum.any?(result, &(&1 == sport_z.abbrev))
      assert Enum.any?(result, &(&1 == "Flex1"))
      assert Enum.any?(result, &(&1 == "Unassigned"))
    end
  end

  describe "all_positions/1" do
    test "returns all positions for a league" do
      sport_b = insert(:sports_league, abbrev: "b")
      sport_c = insert(:sports_league, abbrev: "c")
      sport_a = insert(:sports_league, abbrev: "a")
      insert(:sports_league, abbrev: "z")

      league = insert(:fantasy_league, max_flex_spots: 5)

      insert(:league_sport, fantasy_league: league, sports_league: sport_a)
      insert(:league_sport, fantasy_league: league, sports_league: sport_b)
      insert(:league_sport, fantasy_league: league, sports_league: sport_c)

      result = Store.all_positions(league)

      assert Enum.count(result) == 9
      assert Enum.any?(result, &(&1 == sport_a.abbrev))
      assert Enum.any?(result, &(&1 == "Flex5"))
      refute Enum.any?(result, &(&1 == "Flex6"))
      assert Enum.any?(result, &(&1 == "Unassigned"))
    end
  end

  describe "get_by/1" do
    test "fetches a single RosterPosition from the query" do
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)
      team_a = insert(:fantasy_team)
      team_b = insert(:fantasy_team)

      _ros_a =
        insert(
          :roster_position,
          status: "dropped",
          fantasy_team: team_a,
          fantasy_player: player_a
        )

      ros_b =
        insert(:roster_position, status: "active", fantasy_team: team_a, fantasy_player: player_a)

      _ros_c =
        insert(:roster_position, status: "active", fantasy_team: team_b, fantasy_player: player_a)

      _ros_d =
        insert(:roster_position, status: "active", fantasy_team: team_a, fantasy_player: player_b)

      params = %{
        fantasy_team_id: team_a.id,
        fantasy_player_id: player_a.id,
        status: "active"
      }

      result = Store.get_by(params)

      assert result.id == ros_b.id
    end

    test "returns nil if none found" do
      params = %{
        fantasy_team_id: 1,
        fantasy_player_id: 1,
        status: "active"
      }

      result = Store.get_by(params)

      assert result == nil
    end
  end

  describe "list_all/0" do
    test "returns all roster positions in order by id" do
      ros_a = insert(:roster_position, status: "active")
      ros_b = insert(:roster_position, status: "traded")
      ros_c = insert(:roster_position, status: "active")

      result = Store.list_all()

      assert Enum.map(result, & &1.id) == [ros_a.id, ros_b.id, ros_c.id]
    end
  end

  describe "list_all_active/0" do
    test "returns all active roster positions in order by id" do
      ros_a = insert(:roster_position, status: "active")
      _ros_b = insert(:roster_position, status: "traded")
      ros_c = insert(:roster_position, status: "active")

      result = Store.list_all_active()

      assert Enum.map(result, & &1.id) == [ros_a.id, ros_c.id]
    end
  end

  describe "positions/1" do
    test "returns all primary & flex positions for a league" do
      sport_b = insert(:sports_league, abbrev: "b")
      sport_c = insert(:sports_league, abbrev: "c")
      sport_a = insert(:sports_league, abbrev: "a")
      insert(:sports_league, abbrev: "z")

      league = insert(:fantasy_league, max_flex_spots: 5)

      insert(:league_sport, fantasy_league: league, sports_league: sport_a)
      insert(:league_sport, fantasy_league: league, sports_league: sport_b)
      insert(:league_sport, fantasy_league: league, sports_league: sport_c)

      result = Store.positions(league)

      assert Enum.count(result) == 8
      assert Enum.any?(result, &(&1 == sport_a.abbrev))
      assert Enum.any?(result, &(&1 == "Flex5"))
      refute Enum.any?(result, &(&1 == "Flex6"))
    end
  end

  describe "positions_for_draft/2" do
    test "returns all positions for a championship in a league" do
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      team_a = insert(:fantasy_team, fantasy_league: league)
      team_b = insert(:fantasy_team, fantasy_league: other_league)

      sport = insert(:sports_league)
      other_sport = insert(:sports_league)
      championship = insert(:championship, category: "overall", sports_league: sport)

      player_1 = insert(:fantasy_player, sports_league: sport, draft_pick: true)
      player_2 = insert(:fantasy_player, sports_league: other_sport, draft_pick: true)
      player_3 = insert(:fantasy_player, sports_league: sport, draft_pick: false)
      player_4 = insert(:fantasy_player, sports_league: sport, draft_pick: true)

      pos =
        insert(:roster_position, fantasy_player: player_1, fantasy_team: team_a, status: "active")

      insert(:roster_position, fantasy_player: player_1, fantasy_team: team_b)
      insert(:roster_position, fantasy_player: player_2, fantasy_team: team_a)
      insert(:roster_position, fantasy_player: player_3, fantasy_team: team_a)
      insert(:roster_position, fantasy_player: player_4, fantasy_team: team_a, status: "traded")

      [result] = Store.positions_for_draft(league.id, championship.id)

      assert result.id == pos.id
      assert result.fantasy_player.player_name == player_1.player_name
    end
  end
end
