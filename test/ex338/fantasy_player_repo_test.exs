defmodule Ex338.FantasyPlayerRepoTest do
  use Ex338.DataCase
  alias Ex338.{FantasyPlayer, CalendarAssistant}
  describe "alphabetical_by_league/1" do
    test "returns players alphabetically sorted by league" do
      league_a = insert(:sports_league, league_name: "A")
      league_b = insert(:sports_league, league_name: "B")
      insert(:fantasy_player, player_name: "A", sports_league: league_b)
      insert(:fantasy_player, player_name: "B", sports_league: league_a)
      insert(:fantasy_player, player_name: "C", sports_league: league_a)

      query = FantasyPlayer.alphabetical_by_league(FantasyPlayer)
      query = from f in query, select: f.player_name

      assert Repo.all(query) == ~w(B C A)
    end
  end

  describe "available_players/1" do
    test "returns unowned players in a league for select option" do
      league_a = insert(:sports_league, abbrev: "A")
      league_b = insert(:sports_league, abbrev: "B")
      league_c = insert(:sports_league, abbrev: "C")
      insert(:championship, sports_league: league_a,
        waiver_deadline_at: CalendarAssistant.days_from_now(5))
      insert(:championship, sports_league: league_b,
        waiver_deadline_at: CalendarAssistant.days_from_now(5))
      insert(:championship, sports_league: league_b,
        waiver_deadline_at: CalendarAssistant.days_from_now(-5))
      insert(:championship, sports_league: league_b, year: 2018,
        waiver_deadline_at: CalendarAssistant.days_from_now(360))

      player_a = insert(:fantasy_player, sports_league: league_a)
      player_b = insert(:fantasy_player, sports_league: league_a)
      player_c = insert(:fantasy_player, sports_league: league_b)
      player_d = insert(:fantasy_player, sports_league: league_b)
      _player_e = insert(:fantasy_player, sports_league: league_c)
      player_f = insert(:fantasy_player, sports_league: league_a)

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
      insert(:roster_position, fantasy_team: team_a, fantasy_player: player_a)
      insert(:roster_position, fantasy_team: team_b, fantasy_player: player_b)
      insert(:roster_position, fantasy_team: team_a, fantasy_player: player_d,
        status: "dropped")
      insert(:roster_position, fantasy_team: team_a, fantasy_player: player_f,
        status: "injured_reserve")

      query = FantasyPlayer.available_players(f_league_a.id)

      assert Repo.all(query) == [
        %{player_name: player_b.player_name, league_abbrev: league_a.abbrev,
          id: player_b.id},
        %{player_name: player_c.player_name, league_abbrev: league_b.abbrev,
          id: player_c.id},
        %{player_name: player_d.player_name, league_abbrev: league_b.abbrev,
          id: player_d.id}
      ]
    end

    test "returns players only from sports associated with the league" do
      league_a = insert(:sports_league, abbrev: "A")
      league_b = insert(:sports_league, abbrev: "B")
      insert(:championship, sports_league: league_a,
        waiver_deadline_at: CalendarAssistant.days_from_now(5))
      insert(:championship, sports_league: league_b,
        waiver_deadline_at: CalendarAssistant.days_from_now(5))

      f_league_a = insert(:fantasy_league)
      insert(:league_sport, fantasy_league: f_league_a, sports_league: league_a)
      f_league_b = insert(:fantasy_league)
      insert(:league_sport, fantasy_league: f_league_b, sports_league: league_b)

      player_a = insert(:fantasy_player, sports_league: league_a)
      _player_b = insert(:fantasy_player, sports_league: league_b)

      [result] =
        f_league_a.id
        |> FantasyPlayer.available_players
        |> Repo.all

      assert result.id == player_a.id
    end

    test "returns players only valid during the league year" do
      league_a = insert(:sports_league, abbrev: "A")
      insert(:championship, sports_league: league_a, year: 2018,
        waiver_deadline_at: CalendarAssistant.days_from_now(5))

      f_league_a = insert(:fantasy_league, year: 2018)
      insert(:league_sport, fantasy_league: f_league_a, sports_league: league_a)

      _player_a =
        insert(:fantasy_player, sports_league: league_a, start_year: 2017,
          end_year: 2017)
      player_b =
        insert(:fantasy_player, sports_league: league_a, start_year: 2017,
          end_year: nil)
      player_c =
        insert(:fantasy_player, sports_league: league_a, start_year: 2017,
          end_year: 2019)
      _player_d =
        insert(:fantasy_player, sports_league: league_a, start_year: 2019,
          end_year: nil)

      [result_b, result_c] = results =
        f_league_a.id
        |> FantasyPlayer.available_players
        |> Repo.all

      assert Enum.count(results) == 2
      assert result_b.id == player_b.id
      assert result_c.id == player_c.id
    end
  end

  describe "avail_players_for_champ/1" do
    test "query for unowned players in a league for a championship" do
      league = insert(:fantasy_league)
      league_b = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      team_b = insert(:fantasy_team, team_name: "Axel", fantasy_league: league_b)

      sport = insert(:sports_league)
      other_sport = insert(:sports_league)

      drafted_player =
        insert(:fantasy_player, player_name: "E", draft_pick: false,
          sports_league: sport)
      insert(:roster_position, fantasy_team: team, fantasy_player: drafted_player)
      avail_player =
        insert(:fantasy_player, player_name: "D", draft_pick: false,
          sports_league: sport)
      insert(:roster_position, fantasy_team: team_b, fantasy_player: avail_player)
      unowned_player =
        insert(:fantasy_player, player_name: "C", draft_pick: false,
          sports_league: sport)
      _pick_player =
        insert(:fantasy_player, player_name: "B", draft_pick: true,
          sports_league: sport)
      _other_sport_player =
        insert(:fantasy_player, player_name: "A", draft_pick: false,
          sports_league: other_sport)

      result =
        FantasyPlayer
        |> FantasyPlayer.avail_players_for_champ(league.id, sport.id)
        |> Repo.all

      [result_c, result_d] = result

      assert Enum.count(result) == 2
      assert result_c.id == unowned_player.id
      assert result_d.id == avail_player.id
    end
  end
end
