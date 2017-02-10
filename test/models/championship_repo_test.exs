defmodule Ex338.ChampionshipRepoTest do
  use Ex338.ModelCase
  alias Ex338.{Championship, CalendarAssistant}

  describe "earliest_first/1" do
    test "return championships with earliest date first" do
      insert(:championship,
        title: "A",
        championship_at: Ecto.DateTime.cast!(
          %{day: 17, hour: 0, min: 0, month: 6, sec: 0, year: 2017}
        )
      )
      insert(:championship,
        title: "B",
        championship_at: Ecto.DateTime.cast!(
          %{day: 17, hour: 0, min: 0, month: 5, sec: 0, year: 2017}
        )
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
      player_a = insert(:fantasy_player)
      f_league_a = insert(:fantasy_league)
      f_league_b = insert(:fantasy_league)
      team_a = insert(:fantasy_team, fantasy_league: f_league_a)
      team_b = insert(:fantasy_team, fantasy_league: f_league_b)
      pos = insert(:roster_position, fantasy_team: team_a,
                                     fantasy_player: player_a)
      other_pos = insert(:roster_position, fantasy_team: team_b,
                                            fantasy_player: player_a)
      championship = insert(:championship)
      insert(:championship_result, championship: championship,
                                   fantasy_player: player_a)
      _slot = insert(:championship_slot, championship: championship,
                                         roster_position: pos)
      _other_slot = insert(:championship_slot, championship: championship,
                                               roster_position: other_pos)

      [%{championship_results: [result], championship_slots: [slot]}] =
        Championship
        |> Championship.preload_assocs_by_league(f_league_a.id)
        |> Repo.all

      %{fantasy_player: %{roster_positions: [position]}} = result

      assert position.id == pos.id
      assert position.fantasy_team.id == team_a.id
      assert slot.roster_position.fantasy_team.id == team_a.id
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

  describe "event_championships/1" do
    test "returns all event championships" do
      insert_list(3, :championship, category: "overall")
      insert_list(3, :championship, category: "event")

      result =
        Championship
        |> Championship.event_championships
        |> Repo.all

      assert Enum.count(result) == 3
    end
  end

  describe "by_sport/1" do
    test "returns all championships for a sport" do
      sport = insert(:sports_league)
      other_sport = insert(:sports_league)
      insert_list(3, :championship, sports_league: sport)
      insert_list(3, :championship, sports_league: other_sport)

      result =
        Championship
        |> Championship.by_sport(sport.id)
        |> Repo.all

      assert Enum.count(result) == 3
    end
  end
end
