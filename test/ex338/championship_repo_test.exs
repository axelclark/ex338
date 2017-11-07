defmodule Ex338.ChampionshipRepoTest do
  use Ex338.DataCase
  alias Ex338.{Championship, CalendarAssistant}

  describe "earliest_first/1" do
    test "return championships with earliest date first" do
      insert(
        :championship,
        title: "A",
        championship_at: CalendarAssistant.days_from_now(10)
      )
      insert(
        :championship,
        title: "B",
        championship_at: CalendarAssistant.days_from_now(5)
      )

      query =
        Championship
        |> Championship.earliest_first
        |> select([c], c.title)

      assert Repo.all(query) == ~w(B A)
    end
  end

  describe "future_championships/1" do
    test "return championships in the future" do
      league = insert(:sports_league)
      _prev_event = insert(:championship, sports_league: league,
        title: "A",
        category: "event",
        waiver_deadline_at: CalendarAssistant.days_from_now(-1),
        championship_at:    CalendarAssistant.days_from_now(-5)
      )
      _event = insert(:championship, sports_league: league,
        title: "C",
        category: "overall",
        waiver_deadline_at: CalendarAssistant.days_from_now(1),
        championship_at:    CalendarAssistant.days_from_now(14)
      )
      _other_event = insert(:championship, sports_league: league,
        title: "B",
        category: "event",
        waiver_deadline_at: CalendarAssistant.days_from_now(3),
        championship_at:    CalendarAssistant.days_from_now(19)
      )

      query =
        Championship
        |> Championship.future_championships
        |> select([c], c.title)

      assert Repo.all(query) == ~w(C B)
    end
  end

  describe "future_championships/2" do
    test "return championships in the future for a league" do
      sport_a = insert(:sports_league)
      sport_b = insert(:sports_league)

      league_a = insert(:fantasy_league, year: 2017)
      league_b = insert(:fantasy_league, year: 2017)

      insert(:league_sport, fantasy_league: league_a, sports_league: sport_a)
      insert(:league_sport, fantasy_league: league_b, sports_league: sport_b)

      _prev_event = insert(:championship, sports_league: sport_a,
        title: "A",
        category: "event",
        waiver_deadline_at: CalendarAssistant.days_from_now(-1),
        championship_at:    CalendarAssistant.days_from_now(-5),
        year: 2017
      )
      _event = insert(:championship, sports_league: sport_a,
        title: "C",
        category: "overall",
        waiver_deadline_at: CalendarAssistant.days_from_now(1),
        championship_at:    CalendarAssistant.days_from_now(14),
        year: 2017
      )
      _other_event = insert(:championship, sports_league: sport_a,
        title: "B",
        category: "event",
        waiver_deadline_at: CalendarAssistant.days_from_now(3),
        championship_at:    CalendarAssistant.days_from_now(19),
        year: 2017
      )
      _next_year = insert(:championship,
        title: "C Next Year",
        category: "overall",
        waiver_deadline_at: CalendarAssistant.days_from_now(366),
        year: 2018,
        sports_league: sport_a
      )
      _other_league = insert(:championship,
        title: "D",
        category: "overall",
        waiver_deadline_at: CalendarAssistant.days_from_now(1),
        year: 2017,
        sports_league: sport_b
      )

      query =
        Championship
        |> Championship.future_championships(league_a.id)
        |> select([c], c.title)

      assert Repo.all(query) == ~w(C B)
    end
  end

  describe "all_with_overall_waivers_open/1" do
    test "returns all overall championships with waiver deadline in future" do
      _prev_champ = insert(:championship,
        title: "A",
        category: "overall",
        waiver_deadline_at: CalendarAssistant.days_from_now(-1)
      )
      _open_champ = insert(:championship,
        title: "C",
        category: "overall",
        waiver_deadline_at: CalendarAssistant.days_from_now(1)
      )
      _event = insert(:championship,
        title: "B",
        category: "event",
        waiver_deadline_at: CalendarAssistant.days_from_now(3)
      )

      query =
        Championship
        |> Championship.all_with_overall_waivers_open
        |> select([c], c.title)

      assert Repo.all(query) == ~w(C)
    end
  end

  describe "all_with_overall_waivers_open/2" do
    test "all overall champs in league with waiver deadline in future" do
      sport_a = insert(:sports_league)
      sport_b = insert(:sports_league)

      league_a = insert(:fantasy_league, year: 2017)
      league_b = insert(:fantasy_league, year: 2017)

      insert(:league_sport, fantasy_league: league_a, sports_league: sport_a)
      insert(:league_sport, fantasy_league: league_b, sports_league: sport_b)

      _prev_champ = insert(:championship,
        title: "A",
        category: "overall",
        waiver_deadline_at: CalendarAssistant.days_from_now(-1),
        sports_league: sport_a
      )
      _open_champ = insert(:championship,
        title: "C",
        category: "overall",
        waiver_deadline_at: CalendarAssistant.days_from_now(1),
        sports_league: sport_a
      )
      _event = insert(:championship,
        title: "B",
        category: "event",
        waiver_deadline_at: CalendarAssistant.days_from_now(3),
        sports_league: sport_a
      )
      _next_year = insert(:championship,
        title: "C Next Year",
        category: "overall",
        waiver_deadline_at: CalendarAssistant.days_from_now(366),
        year: 2018,
        sports_league: sport_a
      )
      _other_league = insert(:championship,
        title: "D",
        category: "overall",
        waiver_deadline_at: CalendarAssistant.days_from_now(1),
        sports_league: sport_b
      )

      query =
        Championship
        |> Championship.all_with_overall_waivers_open(league_a.id)
        |> select([c], c.title)

      assert Repo.all(query) == ~w(C)
    end
  end

  describe "preload_assocs/1" do
    test "returns any associated sports leagues" do
      league = insert(:sports_league)
      championship = insert(:championship, sports_league: league)
      player = insert(:fantasy_player, sports_league: league)
      champ_result = insert(:championship_result,
       championship: championship,
       fantasy_player: player
      )

      result =
        Championship
        |> Championship.preload_assocs
        |> Repo.one

      assert result.sports_league.id == league.id
      assert Enum.at(result.championship_results, 0).id == champ_result.id
    end
  end

  describe "preload_assocs_by_league/2" do
    test "preloads all assocs for a league" do
      f_league_a = insert(:fantasy_league)
      f_league_b = insert(:fantasy_league)
      team_a = insert(:fantasy_team, fantasy_league: f_league_a)
      team_b = insert(:fantasy_team, fantasy_league: f_league_b)
      player_a = insert(:fantasy_player)
      pos = insert(:roster_position, fantasy_team: team_a,
        fantasy_player: player_a)
      other_pos = insert(:roster_position, fantasy_team: team_b,
        fantasy_player: player_a)

      sport = insert(:sports_league)
      championship = insert(:championship, category: "overall",
        in_season_draft: true, sports_league: sport)
      insert(:championship_result, championship: championship,
        fantasy_player: player_a)
      insert(:champ_with_events_result, championship: championship,
        fantasy_team: team_a)
      insert(:champ_with_events_result, championship: championship,
        fantasy_team: team_b)
      insert(:championship_slot, championship: championship,
        roster_position: pos)
      insert(:championship_slot, championship: championship,
        roster_position: other_pos)

      pick = insert(:fantasy_player, sports_league: sport, draft_pick: true,
        player_name: "KD Pick #1")
      pick_asset =
        insert(:roster_position, fantasy_team: team_a, fantasy_player: pick)
      horse = insert(:fantasy_player, sports_league: sport, draft_pick: false,
        player_name: "My Horse")
      insert(:in_season_draft_pick, draft_pick_asset: pick_asset,
        championship: championship, position: 1, drafted_player: horse)

      [%{
        championship_results: [result],
        championship_slots: [slot],
        champ_with_events_results: [champ_team],
        in_season_draft_picks: [pick]
      }] =
        Championship
        |> Championship.preload_assocs_by_league(f_league_a.id)
        |> Repo.all

      %{fantasy_player: %{roster_positions: [position]}} = result

      assert position.id == pos.id
      assert position.fantasy_team.id == team_a.id
      assert slot.roster_position.fantasy_team.id == team_a.id
      assert champ_team.fantasy_team.id == team_a.id
      assert pick.draft_pick_asset.fantasy_team.id == team_a.id
      assert pick.drafted_player.id == horse.id
    end
  end

  describe "overall_championships/1" do
    test "returns all overall championships" do
      insert_list(3, :championship, category: "overall")
      insert_list(3, :championship, category: "event")

      result =
        Championship
        |> Championship.overall_championships
        |> Repo.all

      assert Enum.count(result) == 3
    end
  end

  describe "sum_slot_points/3" do
    test "calculates points for each slot" do
      league = insert(:fantasy_league)
      overall = insert(:championship)
      event1 = insert(:championship, overall: overall)
      event2 = insert(:championship, overall: overall)

      team = insert(:fantasy_team, fantasy_league: league)
      player = insert(:fantasy_player)
      pos = insert(:roster_position, fantasy_team: team,
        fantasy_player: player)
      insert(:championship_slot, championship: event1,
        roster_position: pos, slot: 1)
      insert(:championship_slot, championship: event2,
        roster_position: pos, slot: 1)
      insert(:championship_result, championship: event1, points: 5,
        fantasy_player: player)
      insert(:championship_result, championship: event2, points: 1,
        fantasy_player: player)

      team_b = insert(:fantasy_team, fantasy_league: league)
      player_b = insert(:fantasy_player)
      pos_b = insert(:roster_position, fantasy_team: team_b,
        fantasy_player: player_b)
      insert(:championship_slot, championship: event1,
        roster_position: pos_b, slot: 1)
      insert(:championship_slot, championship: event2,
        roster_position: pos_b, slot: 1)
      insert(:championship_result, championship: event1, points: 8,
        fantasy_player: player_b)
      insert(:championship_result, championship: event2, points: 8,
        fantasy_player: player_b)

      other_player = insert(:fantasy_player)
      other_event = insert(:championship)
      other_pos = insert(:roster_position, fantasy_team: team,
        fantasy_player: other_player)
      insert(:championship_slot, championship: other_event,
        roster_position: other_pos, slot: 1)
      insert(:championship_result, championship: other_event, points: 8,
        fantasy_player: other_player)

      result =
        Championship
        |> Championship.sum_slot_points(overall.id, league.id)
        |> Repo.all

      assert result ==
        [%{points: 6, slot: 1, team_name: team.team_name},
         %{points: 16, slot: 1, team_name: team_b.team_name}]
    end

    test "includes positions owned during championship" do
      champ_date = CalendarAssistant.days_from_now(-10)
      before_champ = CalendarAssistant.days_from_now(-15)
      after_champ = CalendarAssistant.days_from_now(-1)

      league = insert(:fantasy_league)
      overall = insert(:championship, championship_at: champ_date)
      event = insert(:championship, overall: overall, championship_at: champ_date)
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)
      player_c = insert(:fantasy_player)
      player_d = insert(:fantasy_player)

      team_a = insert(:fantasy_team, fantasy_league: league, team_name: "A")
      pos_a = insert(:roster_position, fantasy_team: team_a,
        fantasy_player: player_a, active_at: before_champ,
        released_at: after_champ)
      insert(:championship_result, fantasy_player: player_a,
        championship: event, points: 1)
      insert(:championship_slot, championship: event,
        roster_position: pos_a, slot: 1)

      team_b = insert(:fantasy_team, fantasy_league: league, team_name: "B")
      pos_b = insert(:roster_position, fantasy_team: team_b,
        fantasy_player: player_b, active_at: before_champ,
        released_at: nil)
      insert(:championship_result, fantasy_player: player_b,
        championship: event, points: 3)
      insert(:championship_slot, championship: event,
        roster_position: pos_b, slot: 1)

      team_c = insert(:fantasy_team, fantasy_league: league)
      pos_c = insert(:roster_position, fantasy_team: team_c,
        fantasy_player: player_c, active_at: after_champ,
        released_at: nil)
      insert(:championship_result, fantasy_player: player_c,
        championship: event, points: 5)
      insert(:championship_slot, championship: event,
        roster_position: pos_c, slot: 1)

      team_d = insert(:fantasy_team, fantasy_league: league)
      pos_d = insert(:roster_position, fantasy_team: team_d,
        fantasy_player: player_d, active_at: before_champ,
        released_at: before_champ)
      insert(:championship_result, fantasy_player: player_d,
        championship: event, points: 8)
      insert(:championship_slot, championship: event,
        roster_position: pos_d, slot: 1)

      result =
        Championship
        |> Championship.sum_slot_points(overall.id, league.id)
        |> Repo.all

      assert result ==
        [%{points: 1, slot: 1, team_name: team_a.team_name},
         %{points: 3, slot: 1, team_name: team_b.team_name}]
    end
  end

  describe "all_for_league/2" do
    test "returns championships by league" do
      sport_a = insert(:sports_league)
      sport_b = insert(:sports_league)

      champ_a = insert(:championship, sports_league: sport_a, year: 2017)
      _champ_b = insert(:championship, sports_league: sport_b, year: 2017)
      _old_champ_a = insert(:championship, sports_league: sport_a, year: 2016)

      league_a = insert(:fantasy_league, year: 2017)
      league_b = insert(:fantasy_league, year: 2017)

      insert(:league_sport, fantasy_league: league_a, sports_league: sport_a)
      insert(:league_sport, fantasy_league: league_b, sports_league: sport_b)

      result =
        Championship
        |> Championship.all_for_league(league_a.id)
        |> Repo.one

      assert result.id == champ_a.id
    end
  end
end
