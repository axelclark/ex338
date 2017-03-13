defmodule Ex338.ChampionshipSlotRepoTest do
  use Ex338.ModelCase

  alias Ex338.{ChampionshipSlot, CalendarAssistant}

  describe "preload_assocs_by_league/2" do
    test "ordered, includes slots with & without results, only for championship" do
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)
      f_league_a = insert(:fantasy_league)
      championship = insert(:championship)
      other_championship = insert(:championship)
      team_a = insert(:fantasy_team, fantasy_league: f_league_a)
      results_pos = insert(:roster_position, fantasy_team: team_a,
        fantasy_player: player_a)
      no_results_pos = insert(:roster_position, fantasy_team: team_a,
        fantasy_player: player_b)
      insert(:championship_slot, championship: championship,
        roster_position: results_pos, slot: 1)
      insert(:championship_slot, championship: championship,
        roster_position: no_results_pos, slot: 2)
      expected_champ_result =
        insert(:championship_result, championship: championship, points: 8,
          fantasy_player: player_a)
      insert(:championship_result, championship: other_championship, points: 8,
        fantasy_player: player_a)

      [slot_result, slot_no_result] =
        ChampionshipSlot
        |> ChampionshipSlot.preload_assocs_by_league(f_league_a.id)
        |> Repo.all

      %{championship_results: [champ_result]} =
        slot_result.roster_position.fantasy_player

      assert slot_result.roster_position.id == results_pos.id
      assert slot_result.roster_position.fantasy_player.id == player_a.id
      assert slot_no_result.roster_position.id == no_results_pos.id
      assert champ_result.id == expected_champ_result.id
    end

    test "only includes assocs for a fantasy league" do
      player_a = insert(:fantasy_player)
      f_league_a = insert(:fantasy_league)
      f_league_b = insert(:fantasy_league)
      championship = insert(:championship)
      team_a = insert(:fantasy_team, fantasy_league: f_league_a)
      team_b = insert(:fantasy_team, fantasy_league: f_league_b)
      pos_a = insert(:roster_position, fantasy_team: team_a,
        fantasy_player: player_a)
      pos_b = insert(:roster_position, fantasy_team: team_b,
        fantasy_player: player_a)
      insert(:championship_slot, championship: championship,
        roster_position: pos_a)
      insert(:championship_slot, championship: championship,
        roster_position: pos_b)

      result =
        ChampionshipSlot
        |> ChampionshipSlot.preload_assocs_by_league(f_league_a.id)
        |> Repo.one

      assert result.roster_position.id == pos_a.id
    end

    test "only slots with roster positions owned during championship" do
      champ_date = CalendarAssistant.days_from_now(-10)
      before_champ = CalendarAssistant.days_from_now(-15)
      after_champ = CalendarAssistant.days_from_now(-1)

      f_league_a = insert(:fantasy_league)
      championship = insert(:championship, championship_at: champ_date)
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)
      player_c = insert(:fantasy_player)
      player_d = insert(:fantasy_player)

      team_a = insert(:fantasy_team, fantasy_league: f_league_a, team_name: "A")
      pos_a = insert(:roster_position, fantasy_team: team_a,
        fantasy_player: player_a, active_at: before_champ,
        released_at: after_champ)
      insert(:championship_slot, championship: championship,
        roster_position: pos_a)

      team_b = insert(:fantasy_team, fantasy_league: f_league_a, team_name: "B")
      pos_b = insert(:roster_position, fantasy_team: team_a,
        fantasy_player: player_b, active_at: before_champ,
        released_at: nil)
      insert(:championship_slot, championship: championship,
        roster_position: pos_b)

      team_c = insert(:fantasy_team, fantasy_league: f_league_a)
      pos_c = insert(:roster_position, fantasy_team: team_a,
        fantasy_player: player_c, active_at: after_champ,
        released_at: nil)
      insert(:championship_slot, championship: championship,
        roster_position: pos_c)

      team_d = insert(:fantasy_team, fantasy_league: f_league_a)
      pos_d = insert(:roster_position, fantasy_team: team_a,
        fantasy_player: player_d, active_at: before_champ,
        released_at: before_champ)
      insert(:championship_slot, championship: championship,
        roster_position: pos_d)

      [result_a, result_b] =
        ChampionshipSlot
        |> ChampionshipSlot.preload_assocs_by_league(f_league_a.id)
        |> Repo.all

      assert result_a.roster_position.id == pos_b.id
      assert result_b.roster_position.id == pos_a.id
    end
  end
end
