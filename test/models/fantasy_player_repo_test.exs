defmodule Ex338.FantasyPlayerRepoTest do
  use Ex338.ModelCase
  alias Ex338.{FantasyPlayer, CalendarAssistant}
  describe "alphabetical_by_league/1" do
    test "returns players alphabetically sorted by league" do
      league_a = insert(:sports_league, league_name: "A")
      league_b = insert(:sports_league, league_name: "B")
      insert(:fantasy_player, player_name: "A", sports_league: league_b)
      insert(:fantasy_player, player_name: "B", sports_league: league_a)
      insert(:fantasy_player, player_name: "C", sports_league: league_a)

      query = FantasyPlayer |> FantasyPlayer.alphabetical_by_league
      query = from f in query, select: f.player_name

      assert Repo.all(query) == ~w(B C A)
    end
  end
  describe "names_and_ids/1" do
    test "selects names and ids" do
      player_a = insert(:fantasy_player, player_name: "A")
      player_b = insert(:fantasy_player, player_name: "B")

      query = FantasyPlayer |> FantasyPlayer.names_and_ids

      assert Repo.all(query) == [{"A", player_a.id}, {"B", player_b.id}]
    end
  end

  describe "get_available_players/1" do
    test "returns available players in league" do
      league_a = insert(:sports_league, abbrev: "A")
      league_b = insert(:sports_league, abbrev: "B")
      league_c = insert(:sports_league, abbrev: "C")
      insert(:championship, sports_league: league_a,
        waiver_deadline_at: CalendarAssistant.days_from_now(5))
      insert(:championship, sports_league: league_b,
        waiver_deadline_at: CalendarAssistant.days_from_now(5))
      insert(:championship, sports_league: league_b,
        waiver_deadline_at: CalendarAssistant.days_from_now(-5))
      f_league_a = insert(:fantasy_league)
      f_league_b = insert(:fantasy_league)
      team_a = insert(:fantasy_team, fantasy_league: f_league_a)
      team_b = insert(:fantasy_team, fantasy_league: f_league_b)
      player_a = insert(:fantasy_player, sports_league: league_a)
      player_b = insert(:fantasy_player, sports_league: league_a)
      player_c = insert(:fantasy_player, sports_league: league_b)
      _player_d = insert(:fantasy_player, sports_league: league_b)
      _player_e = insert(:fantasy_player, sports_league: league_c)
      insert(:roster_position, fantasy_team: team_a, fantasy_player: player_a)
      insert(:roster_position, fantasy_team: team_b, fantasy_player: player_b)
      insert(:roster_position, fantasy_team: team_a, fantasy_player: player_c,
                               status: "dropped")

      result = FantasyPlayer.get_available_players(f_league_a.id)

      assert Enum.count(result) == 3
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
      player_a = insert(:fantasy_player, sports_league: league_a)
      player_b = insert(:fantasy_player, sports_league: league_a)
      player_c = insert(:fantasy_player, sports_league: league_b)
      player_d = insert(:fantasy_player, sports_league: league_b)
      _player_e = insert(:fantasy_player, sports_league: league_c)
      f_league_a = insert(:fantasy_league)
      f_league_b = insert(:fantasy_league)
      team_a = insert(:fantasy_team, fantasy_league: f_league_a)
      team_b = insert(:fantasy_team, fantasy_league: f_league_b)
      insert(:roster_position, fantasy_team: team_a, fantasy_player: player_a)
      insert(:roster_position, fantasy_team: team_b, fantasy_player: player_b)
      insert(:roster_position, fantasy_team: team_a, fantasy_player: player_d,
                               status: "dropped")

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
  end

  describe "get_next_championship/2" do
    test "returns the next championship for a player" do
      league = insert(:sports_league)
      other_league = insert(:sports_league)
      _prev_event = insert(:championship, sports_league: league,
        championship_at: CalendarAssistant.days_from_now(-5))
      _other_event = insert(:championship, sports_league: other_league,
        championship_at: CalendarAssistant.days_from_now(10))
      event = insert(:championship, sports_league: league,
        championship_at: CalendarAssistant.days_from_now(14))
      player = insert(:fantasy_player, sports_league: league)

      result = FantasyPlayer |> FantasyPlayer.get_next_championship(player.id)

      assert result.championship_at == event.championship_at
    end
  end

  describe "preload_overall_results/1" do
    test "preloads all overall championship results" do
      player  = insert(:fantasy_player)
      overall = insert(:championship, category: "overall")
      event   = insert(:championship, category: "event")
      insert(:championship_result, fantasy_player: player, championship: overall)
      insert(:championship_result, fantasy_player: player, championship: event)

      result = FantasyPlayer
               |> FantasyPlayer.preload_overall_results
               |> Repo.one

      assert Enum.count(result.championship_results) == 1
    end
  end
end
