defmodule Ex338.Waiver.StoreTest do
  use Ex338.DataCase, async: true

  alias Ex338.{Waiver, Waiver.Store, CalendarAssistant, RosterPosition}

  describe "create_waiver" do
    test "creates a waiver" do
      league = insert(:fantasy_league)
      sports_league = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sports_league)
      insert(:championship, sports_league: sports_league,
        waiver_deadline_at: CalendarAssistant.days_from_now(1),
        championship_at:    CalendarAssistant.days_from_now(9))
      player_b = insert(:fantasy_player, sports_league: sports_league)
      team = insert(:fantasy_team, fantasy_league: league)
      player_a = insert(:fantasy_player, sports_league: sports_league)
      insert(:roster_position, fantasy_player: player_a, fantasy_team: team)
      attrs = %{drop_fantasy_player_id: player_a.id,
                add_fantasy_player_id: player_b.id}

      Store.create_waiver(team, attrs)
      waiver = Repo.get_by!(Waiver, attrs)

      assert waiver.fantasy_team_id == team.id
      assert waiver.status == "pending"
    end

    test "drop only waiver is processed immediately" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      sports_league = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sports_league)
      player_a = insert(:fantasy_player, sports_league: sports_league)
      position = insert(:roster_position, fantasy_player: player_a,
                                          fantasy_team: team)
      insert(:championship, sports_league: sports_league,
        waiver_deadline_at: CalendarAssistant.days_from_now(1),
        championship_at:    CalendarAssistant.days_from_now(9))
      attrs = %{drop_fantasy_player_id: player_a.id}

      {:ok, result} = Store.create_waiver(team, attrs)
      position = Repo.get!(RosterPosition, position.id)

      assert result.fantasy_team_id == team.id
      assert result.status == "successful"
      assert position.status == "dropped"
    end
  end

  describe "get_all_waivers/1" do
    test "returns all waivers with assocs in a league" do
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      other_team = insert(:fantasy_team, fantasy_league: other_league)
      insert_list(2, :waiver, fantasy_team: team)
      insert(:waiver, fantasy_team: other_team)

      result = Store.get_all_waivers(league.id)

      assert Enum.count(result) == 2
    end
  end
end
