defmodule Ex338.FantasyPlayersTest do
  use Ex338.DataCase, async: true

  alias Ex338.{CalendarAssistant, FantasyPlayers, FantasyPlayers.FantasyPlayer}

  describe "all_players_for_league/1" do
    test "returns players grouped by sports league" do
      league = insert(:fantasy_league)
      team_a = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      team_b = insert(:fantasy_team, team_name: "Axel", fantasy_league: league)

      league_a = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: league_a)
      league_b = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: league_b)

      player_a = insert(:fantasy_player, sports_league: league_a)
      player_b = insert(:fantasy_player, sports_league: league_b)
      _unowned = insert(:fantasy_player, sports_league: league_b)

      insert(:roster_position, fantasy_team: team_a, fantasy_player: player_a)
      insert(:roster_position, fantasy_team: team_b, fantasy_player: player_b)

      result = FantasyPlayers.all_players_for_league(league)
      [league_a_result, league_b_result] = Enum.map(result, fn {_sport, players} -> players end)

      assert Enum.count(league_a_result) == 1
      assert Enum.count(league_b_result) == 2
    end
  end

  describe "get_avail_draft_pick_players_for_sport/2" do
    test "returns unowned draft pick players in a league for a championship" do
      league = insert(:fantasy_league)
      league_b = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      team_b = insert(:fantasy_team, team_name: "Axel", fantasy_league: league_b)

      sport = insert(:sports_league)
      other_sport = insert(:sports_league)

      insert(:league_sport, fantasy_league: league, sports_league: sport)
      insert(:league_sport, fantasy_league: league_b, sports_league: other_sport)

      drafted_player =
        insert(:fantasy_player, player_name: "E", draft_pick: false, sports_league: sport)

      insert(:roster_position, fantasy_team: team, fantasy_player: drafted_player)

      avail_draft_pick_player =
        insert(:fantasy_player, player_name: "D", draft_pick: true, sports_league: sport)

      insert(:roster_position, fantasy_team: team_b, fantasy_player: avail_draft_pick_player)

      unowned_player =
        insert(:fantasy_player, player_name: "C", draft_pick: true, sports_league: sport)

      _regular_player =
        insert(:fantasy_player, player_name: "B", draft_pick: false, sports_league: sport)

      _other_sport_player =
        insert(:fantasy_player, player_name: "A", draft_pick: false, sports_league: other_sport)

      result = FantasyPlayers.get_avail_draft_pick_players_for_sport(league.id, sport.id)

      [result_c, result_d] = result

      assert Enum.count(result) == 2
      assert result_c.id == unowned_player.id
      assert result_d.id == avail_draft_pick_player.id
    end
  end

  describe "available_players/1" do
    test "returns available players in league" do
      league_a = insert(:sports_league, abbrev: "A")
      league_b = insert(:sports_league, abbrev: "B")
      league_c = insert(:sports_league, abbrev: "C")

      insert(
        :championship,
        sports_league: league_a,
        waiver_deadline_at: CalendarAssistant.days_from_now(5)
      )

      insert(
        :championship,
        sports_league: league_b,
        waiver_deadline_at: CalendarAssistant.days_from_now(5)
      )

      insert(
        :championship,
        sports_league: league_b,
        waiver_deadline_at: CalendarAssistant.days_from_now(-5)
      )

      f_league_a = insert(:fantasy_league)
      insert(:league_sport, fantasy_league: f_league_a, sports_league: league_a)
      insert(:league_sport, fantasy_league: f_league_a, sports_league: league_b)
      insert(:league_sport, fantasy_league: f_league_a, sports_league: league_c)

      f_league_b = insert(:fantasy_league)
      insert(:league_sport, fantasy_league: f_league_b, sports_league: league_a)
      insert(:league_sport, fantasy_league: f_league_b, sports_league: league_b)
      insert(:league_sport, fantasy_league: f_league_b, sports_league: league_c)

      team_a = insert(:fantasy_team, fantasy_league: f_league_a)
      team_b = insert(:fantasy_team, fantasy_league: f_league_b)
      player_a = insert(:fantasy_player, sports_league: league_a)
      player_b = insert(:fantasy_player, sports_league: league_a)
      player_c = insert(:fantasy_player, sports_league: league_b)
      _player_d = insert(:fantasy_player, sports_league: league_b)
      _player_e = insert(:fantasy_player, sports_league: league_c)
      insert(:roster_position, fantasy_team: team_a, fantasy_player: player_a)
      insert(:roster_position, fantasy_team: team_b, fantasy_player: player_b)
      insert(:roster_position, fantasy_team: team_a, fantasy_player: player_c, status: "dropped")

      result = FantasyPlayers.available_players(f_league_a.id)

      assert Enum.count(result) == 3
    end
  end

  describe "available_for_ir_replacement/1" do
    test "returns available players in league for a injured reserve replacement_player" do
      league_a = insert(:sports_league, abbrev: "A")
      league_b = insert(:sports_league, abbrev: "B")
      league_c = insert(:sports_league, abbrev: "C")

      insert(
        :championship,
        sports_league: league_a,
        championship_at: CalendarAssistant.days_from_now(5)
      )

      insert(
        :championship,
        sports_league: league_b,
        championship_at: CalendarAssistant.days_from_now(5)
      )

      insert(
        :championship,
        sports_league: league_b,
        championship_at: CalendarAssistant.days_from_now(-5)
      )

      f_league_a = insert(:fantasy_league)
      insert(:league_sport, fantasy_league: f_league_a, sports_league: league_a)
      insert(:league_sport, fantasy_league: f_league_a, sports_league: league_b)
      insert(:league_sport, fantasy_league: f_league_a, sports_league: league_c)

      f_league_b = insert(:fantasy_league)
      insert(:league_sport, fantasy_league: f_league_b, sports_league: league_a)
      insert(:league_sport, fantasy_league: f_league_b, sports_league: league_b)
      insert(:league_sport, fantasy_league: f_league_b, sports_league: league_c)

      team_a = insert(:fantasy_team, fantasy_league: f_league_a)
      team_b = insert(:fantasy_team, fantasy_league: f_league_b)
      player_a = insert(:fantasy_player, sports_league: league_a)
      player_b = insert(:fantasy_player, sports_league: league_a)
      player_c = insert(:fantasy_player, sports_league: league_b)
      _player_d = insert(:fantasy_player, sports_league: league_b)
      _player_e = insert(:fantasy_player, sports_league: league_c)
      insert(:roster_position, fantasy_team: team_a, fantasy_player: player_a)
      insert(:roster_position, fantasy_team: team_b, fantasy_player: player_b)
      insert(:roster_position, fantasy_team: team_a, fantasy_player: player_c, status: "dropped")

      result = FantasyPlayers.available_for_ir_replacement(f_league_a.id)

      assert Enum.count(result) == 3
    end
  end

  describe "get_avail_players_for_sport/2" do
    test "returns unowned players in a league for a championship" do
      league = insert(:fantasy_league)
      league_b = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      team_b = insert(:fantasy_team, team_name: "Axel", fantasy_league: league_b)

      sport = insert(:sports_league)
      other_sport = insert(:sports_league)

      insert(:league_sport, fantasy_league: league, sports_league: sport)
      insert(:league_sport, fantasy_league: league_b, sports_league: other_sport)

      drafted_player =
        insert(:fantasy_player, player_name: "E", draft_pick: false, sports_league: sport)

      insert(:roster_position, fantasy_team: team, fantasy_player: drafted_player)

      avail_player =
        insert(:fantasy_player, player_name: "D", draft_pick: false, sports_league: sport)

      insert(:roster_position, fantasy_team: team_b, fantasy_player: avail_player)

      unowned_player =
        insert(:fantasy_player, player_name: "C", draft_pick: false, sports_league: sport)

      _pick_player =
        insert(:fantasy_player, player_name: "B", draft_pick: true, sports_league: sport)

      _other_sport_player =
        insert(:fantasy_player, player_name: "A", draft_pick: false, sports_league: other_sport)

      result = FantasyPlayers.get_avail_players_for_sport(league.id, sport.id)

      [result_c, result_d] = result

      assert Enum.count(result) == 2
      assert result_c.id == unowned_player.id
      assert result_d.id == avail_player.id
    end
  end

  describe "get_player!/1" do
    test "get_user!/1 returns the user with given id" do
      player = insert(:fantasy_player)
      assert FantasyPlayers.get_player!(player.id).id == player.id
    end
  end

  describe "get_next_championship/3" do
    test "returns the next championship for a player" do
      league = insert(:fantasy_league, year: 2017)
      sport = insert(:sports_league)
      other_sport = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sport)
      insert(:league_sport, fantasy_league: league, sports_league: other_sport)

      _prev_event =
        insert(
          :championship,
          sports_league: sport,
          championship_at: CalendarAssistant.days_from_now(-5),
          year: 2017
        )

      _other_event =
        insert(
          :championship,
          sports_league: other_sport,
          championship_at: CalendarAssistant.days_from_now(10),
          year: 2017
        )

      event =
        insert(
          :championship,
          sports_league: sport,
          championship_at: CalendarAssistant.days_from_now(14),
          year: 2017
        )

      player = insert(:fantasy_player, sports_league: sport)

      result = FantasyPlayers.get_next_championship(FantasyPlayer, player.id, league.id)

      assert result.championship_at == event.championship_at
    end

    test "ignores championships next year" do
      league = insert(:fantasy_league, year: 2017)
      sport = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sport)

      insert(
        :championship,
        sports_league: sport,
        championship_at: CalendarAssistant.days_from_now(214),
        year: 2018
      )

      player = insert(:fantasy_player, sports_league: sport)

      result = FantasyPlayers.get_next_championship(FantasyPlayer, player.id, league.id)

      assert result == nil
    end
  end

  describe "list_sport_options/0" do
    test "returns all sports abbrevs in order as options" do
      sport_b = insert(:sports_league, abbrev: "b")
      sport_c = insert(:sports_league, abbrev: "c")
      sport_a = insert(:sports_league, abbrev: "a")

      result = FantasyPlayers.list_sport_options()

      assert result == [{"a", sport_a.id}, {"b", sport_b.id}, {"c", sport_c.id}]
    end
  end

  describe "list_sports_abbrevs/1" do
    test "returns sports abbrevs in order" do
      sport_b = insert(:sports_league, abbrev: "b")
      sport_c = insert(:sports_league, abbrev: "c")
      sport_a = insert(:sports_league, abbrev: "a")
      insert(:sports_league, abbrev: "z")

      league = insert(:fantasy_league)

      insert(:league_sport, fantasy_league: league, sports_league: sport_a)
      insert(:league_sport, fantasy_league: league, sports_league: sport_c)
      insert(:league_sport, fantasy_league: league, sports_league: sport_b)

      result = FantasyPlayers.list_sports_abbrevs(league.id)

      assert result == ~w(a b c)
    end
  end

  describe "list_sports_abbrevs/0" do
    test "returns all sports abbrevs in order" do
      sport_b = insert(:sports_league, abbrev: "b")
      sport_c = insert(:sports_league, abbrev: "c")
      sport_a = insert(:sports_league, abbrev: "a")
      insert(:sports_league, abbrev: "z")

      league = insert(:fantasy_league)

      insert(:league_sport, fantasy_league: league, sports_league: sport_a)
      insert(:league_sport, fantasy_league: league, sports_league: sport_c)
      insert(:league_sport, fantasy_league: league, sports_league: sport_b)

      result = FantasyPlayers.list_sports_abbrevs()

      assert result == ~w(a b c z)
    end
  end

  describe "player_with_sport!/2" do
    test "returns a player with the sports league preloaded" do
      sport = insert(:sports_league)
      player = insert(:fantasy_player, sports_league: sport)

      result = FantasyPlayers.player_with_sport!(FantasyPlayer, player.id)

      assert result.sports_league.id == sport.id
    end
  end
end
