defmodule Ex338.FantasyPlayerRepoTest do
  use Ex338.DataCase
  alias Ex338.{FantasyPlayer, CalendarAssistant}

  describe "active_players/2" do
    test "returns players only valid during the league year" do
      sport = insert(:sports_league, abbrev: "A")

      league =
        insert(:fantasy_league,
          championships_start_at: DateTime.from_naive!(~N[2017-01-01 00:00:00.000], "Etc/UTC"),
          championships_end_at: DateTime.from_naive!(~N[2017-12-31 11:59:00.000], "Etc/UTC")
        )

      insert(:league_sport, fantasy_league: league, sports_league: sport)

      _archived_before_league_start =
        insert(:fantasy_player,
          sports_league: sport,
          available_starting_at: DateTime.from_naive!(~N[2016-01-01 00:00:00.000], "Etc/UTC"),
          archived_at: DateTime.from_naive!(~N[2016-12-31 00:00:00.000], "Etc/UTC")
        )

      player_a =
        insert(:fantasy_player,
          sports_league: sport,
          available_starting_at: DateTime.from_naive!(~N[2016-01-01 00:00:00.000], "Etc/UTC"),
          archived_at: DateTime.from_naive!(~N[2017-12-01 00:00:00.000], "Etc/UTC")
        )

      player_b =
        insert(:fantasy_player,
          sports_league: sport,
          available_starting_at: DateTime.from_naive!(~N[2017-02-01 00:00:00.000], "Etc/UTC"),
          archived_at: DateTime.from_naive!(~N[2017-12-01 00:00:00.000], "Etc/UTC")
        )

      player_c =
        insert(:fantasy_player,
          sports_league: sport,
          available_starting_at: DateTime.from_naive!(~N[2017-02-01 00:00:00.000], "Etc/UTC"),
          archived_at: DateTime.from_naive!(~N[2018-12-01 00:00:00.000], "Etc/UTC")
        )

      player_d =
        insert(:fantasy_player,
          sports_league: sport,
          available_starting_at: DateTime.from_naive!(~N[2016-01-01 00:00:00.000], "Etc/UTC"),
          archived_at: nil
        )

      _started_after_league_end =
        insert(:fantasy_player,
          sports_league: sport,
          available_starting_at: DateTime.from_naive!(~N[2018-02-01 00:00:00.000], "Etc/UTC"),
          archived_at: DateTime.from_naive!(~N[2018-12-31 00:00:00.000], "Etc/UTC")
        )

      [result_a, result_b, result_c, result_d] =
        results =
        FantasyPlayer
        |> FantasyPlayer.active_players(league.id)
        |> Repo.all()

      assert Enum.count(results) == 4
      assert result_a.id == player_a.id
      assert result_b.id == player_b.id
      assert result_c.id == player_c.id
      assert result_d.id == player_d.id
    end
  end

  describe "alphabetical_by_league/2" do
    test "returns players alphabetically sorted by league" do
      league_a = insert(:sports_league, league_name: "A")
      league_b = insert(:sports_league, league_name: "B")
      insert(:fantasy_player, player_name: "A", sports_league: league_b)
      insert(:fantasy_player, player_name: "B", sports_league: league_a)
      insert(:fantasy_player, player_name: "C", sports_league: league_a)

      query = FantasyPlayer.alphabetical_by_league(FantasyPlayer)
      query = from(f in query, select: f.player_name)

      assert Repo.all(query) == ~w(B C A)
    end
  end

  describe "available_players/2" do
    test "returns unowned players in a league for select option" do
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

      insert(
        :championship,
        sports_league: league_b,
        waiver_deadline_at: CalendarAssistant.days_from_now(360),
        championship_at: CalendarAssistant.days_from_now(365)
      )

      player_a = insert(:fantasy_player, sports_league: league_a, player_name: "A")
      player_b = insert(:fantasy_player, sports_league: league_a, player_name: "B")
      player_c = insert(:fantasy_player, sports_league: league_b, player_name: "C")
      player_d = insert(:fantasy_player, sports_league: league_b, player_name: "D")
      _player_e = insert(:fantasy_player, sports_league: league_c, player_name: "E")
      player_f = insert(:fantasy_player, sports_league: league_a, player_name: "F")

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
      insert(:roster_position, fantasy_team: team_a, fantasy_player: player_d, status: "dropped")

      insert(
        :roster_position,
        fantasy_team: team_a,
        fantasy_player: player_f,
        status: "injured_reserve"
      )

      result =
        FantasyPlayer
        |> FantasyPlayer.available_players(f_league_a.id)
        |> Repo.all()
        |> Enum.map(& &1.id)

      assert result == [player_b.id, player_c.id, player_d.id]
    end

    test "returns players only from sports associated with the league" do
      league_a = insert(:sports_league, abbrev: "A")
      league_b = insert(:sports_league, abbrev: "B")

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

      f_league_a = insert(:fantasy_league)
      insert(:league_sport, fantasy_league: f_league_a, sports_league: league_a)
      f_league_b = insert(:fantasy_league)
      insert(:league_sport, fantasy_league: f_league_b, sports_league: league_b)

      player_a = insert(:fantasy_player, sports_league: league_a)
      _player_b = insert(:fantasy_player, sports_league: league_b)

      result =
        FantasyPlayer
        |> FantasyPlayer.available_players(f_league_a.id)
        |> Repo.one()

      assert result.id == player_a.id
    end

    test "returns players only valid during the league year" do
      sport = insert(:sports_league, abbrev: "A")

      insert(
        :championship,
        sports_league: sport,
        waiver_deadline_at: CalendarAssistant.days_from_now(5),
        championship_at: DateTime.from_naive!(~N[2017-03-01 00:00:00.000], "Etc/UTC")
      )

      league =
        insert(:fantasy_league,
          championships_start_at: DateTime.from_naive!(~N[2017-01-01 00:00:00.000], "Etc/UTC"),
          championships_end_at: DateTime.from_naive!(~N[2017-12-31 11:59:00.000], "Etc/UTC")
        )

      insert(:league_sport, fantasy_league: league, sports_league: sport)

      _archived_before_league_start =
        insert(:fantasy_player,
          sports_league: sport,
          available_starting_at: DateTime.from_naive!(~N[2016-01-01 00:00:00.000], "Etc/UTC"),
          archived_at: DateTime.from_naive!(~N[2016-12-31 00:00:00.000], "Etc/UTC")
        )

      player_a =
        insert(:fantasy_player,
          sports_league: sport,
          available_starting_at: DateTime.from_naive!(~N[2016-01-01 00:00:00.000], "Etc/UTC"),
          archived_at: DateTime.from_naive!(~N[2017-12-01 00:00:00.000], "Etc/UTC")
        )

      player_b =
        insert(:fantasy_player,
          sports_league: sport,
          available_starting_at: DateTime.from_naive!(~N[2017-02-01 00:00:00.000], "Etc/UTC"),
          archived_at: DateTime.from_naive!(~N[2017-12-01 00:00:00.000], "Etc/UTC")
        )

      player_c =
        insert(:fantasy_player,
          sports_league: sport,
          available_starting_at: DateTime.from_naive!(~N[2017-02-01 00:00:00.000], "Etc/UTC"),
          archived_at: DateTime.from_naive!(~N[2018-12-01 00:00:00.000], "Etc/UTC")
        )

      player_d =
        insert(:fantasy_player,
          sports_league: sport,
          available_starting_at: DateTime.from_naive!(~N[2016-01-01 00:00:00.000], "Etc/UTC"),
          archived_at: nil
        )

      _started_after_league_end =
        insert(:fantasy_player,
          sports_league: sport,
          available_starting_at: DateTime.from_naive!(~N[2018-02-01 00:00:00.000], "Etc/UTC"),
          archived_at: DateTime.from_naive!(~N[2018-12-31 00:00:00.000], "Etc/UTC")
        )

      [result_a, result_b, result_c, result_d] =
        results =
        FantasyPlayer
        |> FantasyPlayer.available_players(league.id)
        |> Repo.all()

      assert Enum.count(results) == 4
      assert result_a.id == player_a.id
      assert result_b.id == player_b.id
      assert result_c.id == player_c.id
      assert result_d.id == player_d.id
    end
  end

  describe "avail_players_for_sport/1" do
    test "query for unowned players in a league for a championship" do
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

      result =
        FantasyPlayer
        |> FantasyPlayer.avail_players_for_sport(league.id, sport.id)
        |> Repo.all()

      [result_c, result_d] = result

      assert Enum.count(result) == 2
      assert result_c.id == unowned_player.id
      assert result_d.id == avail_player.id
    end
  end

  describe "by_league/2" do
    test "returns players only from sports associated with the league" do
      sport_a = insert(:sports_league, abbrev: "A")
      sport_b = insert(:sports_league, abbrev: "B")

      league_a = insert(:fantasy_league)
      league_b = insert(:fantasy_league)

      insert(:league_sport, fantasy_league: league_a, sports_league: sport_a)
      insert(:league_sport, fantasy_league: league_b, sports_league: sport_b)

      player_a = insert(:fantasy_player, sports_league: sport_a)
      _player_b = insert(:fantasy_player, sports_league: sport_b)

      result =
        FantasyPlayer
        |> FantasyPlayer.by_league(league_a.id)
        |> Repo.one()

      assert result.id == player_a.id
    end
  end

  describe "by_sport/2" do
    test "returns players only from a sport" do
      sport_a = insert(:sports_league)
      sport_b = insert(:sports_league)

      player_a = insert(:fantasy_player, sports_league: sport_a)
      _player_b = insert(:fantasy_player, sports_league: sport_b)

      result =
        FantasyPlayer
        |> FantasyPlayer.by_sport(sport_a.id)
        |> Repo.one()

      assert result.id == player_a.id
    end
  end

  describe "is_draft_pick/1" do
    test "returns players not draft picks" do
      _player_a = insert(:fantasy_player, draft_pick: false)
      player_b = insert(:fantasy_player, draft_pick: true)

      result =
        FantasyPlayer
        |> FantasyPlayer.is_draft_pick()
        |> Repo.one()

      assert result.id == player_b.id
    end
  end

  describe "not_draft_pick/1" do
    test "returns players not draft picks" do
      player_a = insert(:fantasy_player, draft_pick: false)
      _player_b = insert(:fantasy_player, draft_pick: true)

      result =
        FantasyPlayer
        |> FantasyPlayer.not_draft_pick()
        |> Repo.one()

      assert result.id == player_a.id
    end
  end

  describe "order_by_name/1" do
    test "returns players ordered by the name" do
      player_a = insert(:fantasy_player, player_name: "A")
      player_c = insert(:fantasy_player, player_name: "C")
      player_b = insert(:fantasy_player, player_name: "B")

      result =
        FantasyPlayer
        |> FantasyPlayer.order_by_name()
        |> Repo.all()
        |> Enum.map(& &1.id)

      assert result == [player_a.id, player_b.id, player_c.id]
    end
  end

  describe "order_by_sport_abbrev/1" do
    test "returns players ordered by sport abbrev" do
      sport_a = insert(:sports_league, abbrev: "A")
      sport_b = insert(:sports_league, abbrev: "B")

      player_a = insert(:fantasy_player, sports_league: sport_b)
      player_b = insert(:fantasy_player, sports_league: sport_a)

      result =
        FantasyPlayer
        |> FantasyPlayer.order_by_sport_abbrev()
        |> Repo.all()
        |> Enum.map(& &1.id)

      assert result == [player_b.id, player_a.id]
    end
  end

  describe "order_by_sport_name/1" do
    test "returns players ordered by sport name" do
      sport_a = insert(:sports_league, league_name: "A")
      sport_b = insert(:sports_league, league_name: "B")

      player_a = insert(:fantasy_player, sports_league: sport_b)
      player_b = insert(:fantasy_player, sports_league: sport_a)

      result =
        FantasyPlayer
        |> FantasyPlayer.order_by_sport_name()
        |> Repo.all()
        |> Enum.map(& &1.id)

      assert result == [player_b.id, player_a.id]
    end
  end

  describe "preload_sport/1" do
    test "returns players only from a sport" do
      sport = insert(:sports_league)
      insert(:fantasy_player, sports_league: sport)

      result =
        FantasyPlayer
        |> FantasyPlayer.preload_sport()
        |> Repo.one()

      assert result.sports_league.id == sport.id
    end
  end

  describe "unowned_players/2" do
    test "returns unowned players in a league for select option" do
      sport_a = insert(:sports_league, abbrev: "A")
      sport_b = insert(:sports_league, abbrev: "B")

      player_a = insert(:fantasy_player, sports_league: sport_a)
      player_b = insert(:fantasy_player, sports_league: sport_a)
      player_c = insert(:fantasy_player, sports_league: sport_b)
      player_d = insert(:fantasy_player, sports_league: sport_b)
      player_f = insert(:fantasy_player, sports_league: sport_a)

      league_a = insert(:fantasy_league)
      league_b = insert(:fantasy_league)

      team_a = insert(:fantasy_team, fantasy_league: league_a)
      team_b = insert(:fantasy_team, fantasy_league: league_b)
      insert(:roster_position, fantasy_team: team_a, fantasy_player: player_a)
      insert(:roster_position, fantasy_team: team_b, fantasy_player: player_b)
      insert(:roster_position, fantasy_team: team_a, fantasy_player: player_d, status: "dropped")

      insert(
        :roster_position,
        fantasy_team: team_a,
        fantasy_player: player_f,
        status: "injured_reserve"
      )

      result =
        FantasyPlayer
        |> FantasyPlayer.unowned_players(league_a.id)
        |> FantasyPlayer.order_by_name()
        |> Repo.all()
        |> Enum.map(& &1.id)
        |> Enum.sort()

      assert result == [player_b.id, player_c.id, player_d.id]
    end
  end

  describe "with_waivers_open/2" do
    test "returns players with overall waiver deadline in the future" do
      sport_open = insert(:sports_league)
      sport_closed = insert(:sports_league)
      sport_next_year = insert(:sports_league)
      sport_not_in_league = insert(:sports_league)

      insert(
        :championship,
        sports_league: sport_open,
        waiver_deadline_at: CalendarAssistant.days_from_now(5)
      )

      insert(
        :championship,
        sports_league: sport_closed,
        waiver_deadline_at: CalendarAssistant.days_from_now(-5)
      )

      insert(
        :championship,
        sports_league: sport_next_year,
        waiver_deadline_at: CalendarAssistant.days_from_now(360),
        championship_at: CalendarAssistant.days_from_now(365)
      )

      insert(
        :championship,
        sports_league: sport_not_in_league,
        waiver_deadline_at: CalendarAssistant.days_from_now(5)
      )

      player_a = insert(:fantasy_player, sports_league: sport_open)
      insert(:fantasy_player, sports_league: sport_closed)
      insert(:fantasy_player, sports_league: sport_next_year)
      insert(:fantasy_player, sports_league: sport_not_in_league)

      league = insert(:fantasy_league, year: 2017)
      insert(:league_sport, fantasy_league: league, sports_league: sport_open)
      insert(:league_sport, fantasy_league: league, sports_league: sport_closed)
      insert(:league_sport, fantasy_league: league, sports_league: sport_next_year)

      result =
        FantasyPlayer
        |> FantasyPlayer.with_waivers_open(league.id)
        |> Repo.one()

      assert result.id == player_a.id
    end
  end

  describe "with_teams_for_league/2" do
    test "returns all players with rank and any owners in a league" do
      s_league = insert(:sports_league)

      jan_2016 = DateTime.from_naive!(~N[2016-01-01 00:00:00.000], "Etc/UTC")

      player_a =
        insert(:fantasy_player,
          player_name: "A",
          sports_league: s_league,
          available_starting_at: jan_2016
        )

      player_b =
        insert(:fantasy_player,
          player_name: "B",
          sports_league: s_league,
          available_starting_at: jan_2016
        )

      _player_c =
        insert(:fantasy_player,
          player_name: "C",
          sports_league: s_league,
          available_starting_at: jan_2016
        )

      player_d =
        insert(:fantasy_player,
          player_name: "D",
          sports_league: s_league,
          available_starting_at: jan_2016
        )

      _player_e =
        insert(
          :fantasy_player,
          player_name: "E",
          sports_league: s_league,
          available_starting_at: DateTime.from_naive!(~N[2016-01-01 00:00:00.000], "Etc/UTC"),
          archived_at: DateTime.from_naive!(~N[2016-12-31 00:00:00.000], "Etc/UTC")
        )

      {:ok, aug_start, _} = DateTime.from_iso8601("2018-08-23T23:50:07Z")
      {:ok, may_end, _} = DateTime.from_iso8601("2019-05-23T23:50:07Z")

      f_league_a =
        insert(:fantasy_league,
          year: 2018,
          championships_start_at: aug_start,
          championships_end_at: may_end
        )

      f_league_b =
        insert(:fantasy_league,
          year: 2018,
          championships_start_at: aug_start,
          championships_end_at: may_end
        )

      insert(:league_sport, fantasy_league: f_league_a, sports_league: s_league)
      insert(:league_sport, fantasy_league: f_league_b, sports_league: s_league)

      team_a = insert(:fantasy_team, fantasy_league: f_league_a)
      team_b = insert(:fantasy_team, fantasy_league: f_league_b)
      insert(:roster_position, fantasy_team: team_a, fantasy_player: player_a, status: "active")
      insert(:roster_position, fantasy_team: team_b, fantasy_player: player_b, status: "active")

      insert(
        :roster_position,
        fantasy_team: team_a,
        fantasy_player: player_d,
        status: "injured_reserve"
      )

      {:ok, oct_this_year, _} = DateTime.from_iso8601("2018-10-23T23:50:07Z")

      championship =
        insert(:championship, category: "overall", year: 2018, championship_at: oct_this_year)

      event_champ =
        insert(:championship, category: "event", year: 2018, championship_at: oct_this_year)

      _champ_result =
        insert(
          :championship_result,
          championship: championship,
          fantasy_player: player_a,
          rank: 1,
          points: 8
        )

      _event_result =
        insert(
          :championship_result,
          championship: event_champ,
          fantasy_player: player_b,
          rank: 1,
          points: 8
        )

      {:ok, last_year, _} = DateTime.from_iso8601("2017-01-23T23:50:07Z")

      old_championship =
        insert(:championship, category: "overall", year: 2017, championship_at: last_year)

      _old_champ_result =
        insert(
          :championship_result,
          championship: old_championship,
          fantasy_player: player_b,
          rank: 1,
          points: 8
        )

      results =
        FantasyPlayer
        |> FantasyPlayer.with_teams_for_league(f_league_a)
        |> Repo.all()

      assert Enum.map(results, & &1.player_name) == ~w(A B C D)
      assert Enum.map(results, &get_team_name/1) == [team_a.team_name, [], [], team_a.team_name]
      assert Enum.map(results, &get_rank/1) == [1, [], [], []]
    end

    test "returns sports associated with a fantasy league" do
      sport_a = insert(:sports_league)
      sport_b = insert(:sports_league)
      player_a = insert(:fantasy_player, sports_league: sport_a)
      _player_b = insert(:fantasy_player, sports_league: sport_b)

      league_a = insert(:fantasy_league)
      league_b = insert(:fantasy_league)
      insert(:league_sport, fantasy_league: league_a, sports_league: sport_a)
      insert(:league_sport, fantasy_league: league_b, sports_league: sport_b)

      [result] =
        FantasyPlayer
        |> FantasyPlayer.with_teams_for_league(league_a)
        |> Repo.all()

      assert result.player_name == player_a.player_name
    end

    test "returns in order by sports league name then player name" do
      s_league_a = insert(:sports_league, league_name: "A")
      s_league_b = insert(:sports_league, league_name: "B")

      insert(:fantasy_player, player_name: "A", sports_league: s_league_b)
      insert(:fantasy_player, player_name: "B", sports_league: s_league_a)
      insert(:fantasy_player, player_name: "C", sports_league: s_league_b)
      insert(:fantasy_player, player_name: "D", sports_league: s_league_a)

      f_league_a = insert(:fantasy_league, year: 2018)
      insert(:league_sport, fantasy_league: f_league_a, sports_league: s_league_a)
      insert(:league_sport, fantasy_league: f_league_a, sports_league: s_league_b)

      results =
        FantasyPlayer
        |> FantasyPlayer.with_teams_for_league(f_league_a)
        |> Repo.all()

      assert Enum.map(results, & &1.player_name) == ~w(B D A C)
    end
  end

  defp get_team_name(%{roster_positions: [position]}), do: position.fantasy_team.team_name
  defp get_team_name(%{roster_positions: []}), do: []

  defp get_rank(%{championship_results: [result]}), do: result.rank
  defp get_rank(%{championship_results: []}), do: []
end
