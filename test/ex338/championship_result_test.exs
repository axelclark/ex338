defmodule Ex338.ChampionshipResultTest do
  use Ex338.DataCase

  alias Ex338.{ChampionshipResult, CalendarAssistant}

  @valid_attrs %{points: 8, rank: 1, fantasy_player_id: 2, championship_id: 3}
  @invalid_attrs %{}

  describe "before_date_in_year/2" do
    test "returns all championships before a date in a year" do
      {:ok, last_year, _} = DateTime.from_iso8601("2017-01-23T23:50:07Z")
      {:ok, may_date, _} = DateTime.from_iso8601("2018-05-23T23:50:07Z")
      {:ok, oct_date, _} = DateTime.from_iso8601("2018-10-23T23:50:07Z")
      {:ok, jun_date, _} = DateTime.from_iso8601("2018-06-01T00:00:00Z")

      old_champ = insert(:championship, year: 2017, championship_at: last_year)
      may_champ = insert(:championship, year: 2018, championship_at: may_date)
      oct_champ = insert(:championship, year: 2018, championship_at: oct_date)

      _old_result = insert(:championship_result, championship: old_champ)
      may_result = insert(:championship_result, championship: may_champ)
      _oct_result = insert(:championship_result, championship: oct_champ)

      result =
        ChampionshipResult
        |> ChampionshipResult.before_date_in_year(jun_date)
        |> Repo.one()

      assert result.id == may_result.id
    end
  end

  describe "by_year/2" do
    test "returns all championships for a year" do
      championship = insert(:championship, year: 2018)
      old_championship = insert(:championship, year: 2017)
      new = insert(:championship_result, championship: championship)
      _old = insert(:championship_result, championship: old_championship)

      result =
        ChampionshipResult
        |> ChampionshipResult.by_year(championship.year)
        |> Repo.one()

      assert result.id == new.id
    end
  end

  describe "changeset/2" do
    test "changeset with valid attributes" do
      changeset = ChampionshipResult.changeset(%ChampionshipResult{}, @valid_attrs)

      assert changeset.valid?
    end

    test "changeset with invalid attributes" do
      changeset = ChampionshipResult.changeset(%ChampionshipResult{}, @invalid_attrs)

      refute changeset.valid?
    end
  end

  describe "from_range/3" do
    test "returns all championships between two datetimes" do
      {:ok, last_year, _} = DateTime.from_iso8601("2017-01-23T23:50:07Z")
      {:ok, oct_this_year, _} = DateTime.from_iso8601("2018-10-23T23:50:07Z")
      {:ok, jan_next_year, _} = DateTime.from_iso8601("2019-01-23T23:50:07Z")
      {:ok, jun_next_year, _} = DateTime.from_iso8601("2019-06-01T00:00:00Z")

      old_champ = insert(:championship, year: 2017, championship_at: last_year)
      oct_champ = insert(:championship, year: 2018, championship_at: oct_this_year)
      jan_champ = insert(:championship, year: 2019, championship_at: jan_next_year)
      jun_champ = insert(:championship, year: 2019, championship_at: jun_next_year)

      _old_result = insert(:championship_result, championship: old_champ)
      oct_result = insert(:championship_result, championship: oct_champ)
      jan_result = insert(:championship_result, championship: jan_champ)
      _jun_result = insert(:championship_result, championship: jun_champ)

      {:ok, aug_start, _} = DateTime.from_iso8601("2018-08-23T23:50:07Z")
      {:ok, may_end, _} = DateTime.from_iso8601("2019-05-23T23:50:07Z")

      results =
        ChampionshipResult
        |> ChampionshipResult.from_range(aug_start, may_end)
        |> Repo.all()

      assert Enum.map(results, & &1.id) == [oct_result.id, jan_result.id]
    end
  end

  describe "only_overall/1" do
    test "returns all championships" do
      overall = insert(:championship, category: "overall")
      event = insert(:championship, category: "event")
      overall_result = insert(:championship_result, championship: overall)
      insert(:championship_result, championship: event)

      result =
        ChampionshipResult
        |> ChampionshipResult.only_overall()
        |> Repo.one()

      assert result.id == overall_result.id
    end
  end

  describe "order_by_points/1" do
    test "returns championship results in order by points then rank" do
      insert(:championship_result, points: 8, rank: 1)
      insert(:championship_result, points: 5, rank: 2)
      insert(:championship_result, points: 3, rank: 4)
      insert(:championship_result, points: 3, rank: 3)
      insert(:championship_result, points: -1, rank: 0)

      result =
        ChampionshipResult
        |> ChampionshipResult.order_by_points_rank()
        |> select([c], c.rank)
        |> Repo.all()

      assert result == [1, 2, 3, 4, 0]
    end
  end

  describe "overall_by_year/2" do
    test "returns all overall championships for a year" do
      championship = insert(:championship, category: "overall", year: 2018)
      event = insert(:championship, category: "event", year: 2018)
      old_championship = insert(:championship, category: "overall", year: 2017)
      new = insert(:championship_result, championship: championship)
      _old = insert(:championship_result, championship: old_championship)
      _event = insert(:championship_result, championship: event)

      result =
        ChampionshipResult
        |> ChampionshipResult.overall_by_year(championship.year)
        |> Repo.one()

      assert result.id == new.id
    end
  end

  describe "overall_before_date_in_year/2" do
    test "returns all overall championships for a year" do
      {:ok, last_year, _} = DateTime.from_iso8601("2017-01-23T23:50:07Z")
      {:ok, may_date, _} = DateTime.from_iso8601("2018-05-23T23:50:07Z")
      {:ok, oct_date, _} = DateTime.from_iso8601("2018-10-23T23:50:07Z")
      {:ok, jun_date, _} = DateTime.from_iso8601("2018-06-01T00:00:00Z")

      old_champ = insert(:championship, year: 2017, championship_at: last_year)
      may_champ = insert(:championship, year: 2018, championship_at: may_date)
      may_event = insert(:championship, year: 2018, championship_at: may_date, category: "event")
      oct_champ = insert(:championship, year: 2018, championship_at: oct_date)

      _old_result = insert(:championship_result, championship: old_champ)
      may_result = insert(:championship_result, championship: may_champ)
      _may_event_result = insert(:championship_result, championship: may_event)
      _oct_result = insert(:championship_result, championship: oct_champ)

      result =
        ChampionshipResult
        |> ChampionshipResult.overall_before_date_in_year(jun_date)
        |> Repo.one()

      assert result.id == may_result.id
    end
  end

  describe "preload_assocs_by_league/2" do
    test "preloads all assocs for a league" do
      player_a = insert(:fantasy_player)
      f_league_a = insert(:fantasy_league)
      f_league_b = insert(:fantasy_league)
      team_a = insert(:fantasy_team, fantasy_league: f_league_a)
      team_b = insert(:fantasy_team, fantasy_league: f_league_b)

      pos =
        insert(
          :roster_position,
          fantasy_team: team_a,
          fantasy_player: player_a
        )

      _other_pos =
        insert(
          :roster_position,
          fantasy_team: team_b,
          fantasy_player: player_a
        )

      insert(:championship_result, fantasy_player: player_a)

      [%{fantasy_player: %{roster_positions: [position]}}] =
        ChampionshipResult
        |> ChampionshipResult.preload_assocs_by_league(f_league_a.id)
        |> Repo.all()

      assert position.id == pos.id
      assert position.fantasy_team.id == team_a.id
    end

    test "preloads results without positions" do
      championship_result = insert(:championship_result)
      f_league_a = insert(:fantasy_league)

      result =
        ChampionshipResult
        |> ChampionshipResult.preload_assocs_by_league(f_league_a.id)
        |> Repo.one()

      assert result.id == championship_result.id
    end

    test "preloads ordered positions owned during championship" do
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

      pos_a =
        insert(
          :roster_position,
          fantasy_team: team_a,
          fantasy_player: player_a,
          active_at: before_champ,
          released_at: after_champ
        )

      a =
        insert(
          :championship_result,
          fantasy_player: player_a,
          championship: championship,
          points: 1
        )

      team_b = insert(:fantasy_team, fantasy_league: f_league_a, team_name: "B")

      pos_b =
        insert(
          :roster_position,
          fantasy_team: team_b,
          fantasy_player: player_b,
          active_at: before_champ,
          released_at: nil
        )

      b =
        insert(
          :championship_result,
          fantasy_player: player_b,
          championship: championship,
          points: 3
        )

      team_c = insert(:fantasy_team, fantasy_league: f_league_a)

      _pos_c =
        insert(
          :roster_position,
          fantasy_team: team_c,
          fantasy_player: player_c,
          active_at: after_champ,
          released_at: nil
        )

      c =
        insert(
          :championship_result,
          fantasy_player: player_c,
          championship: championship,
          points: 5
        )

      team_d = insert(:fantasy_team, fantasy_league: f_league_a)

      _pos_d =
        insert(
          :roster_position,
          fantasy_team: team_d,
          fantasy_player: player_d,
          active_at: before_champ,
          released_at: before_champ
        )

      d =
        insert(
          :championship_result,
          fantasy_player: player_d,
          championship: championship,
          points: 8
        )

      [result_d, result_c, result_b, result_a] =
        ChampionshipResult
        |> ChampionshipResult.preload_assocs_by_league(f_league_a.id)
        |> Repo.all()

      %{fantasy_player: %{roster_positions: [position_a]}} = result_a
      %{fantasy_player: %{roster_positions: [position_b]}} = result_b

      assert result_a.id == a.id
      assert position_a.id == pos_a.id
      assert result_b.id == b.id
      assert position_b.id == pos_b.id
      assert result_c.id == c.id
      assert result_d.id == d.id
    end

    test "preloads roster position when there are multiple results" do
      active_date = CalendarAssistant.days_from_now(-30)
      champ_a_date = CalendarAssistant.days_from_now(-15)
      champ_b_date = CalendarAssistant.days_from_now(-1)

      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      player = insert(:fantasy_player)

      champ_a = insert(:championship, championship_at: champ_a_date)
      champ_b = insert(:championship, championship_at: champ_b_date)

      _pos =
        insert(
          :roster_position,
          fantasy_team: team,
          fantasy_player: player,
          active_at: active_date,
          released_at: nil
        )

      _a_result =
        insert(:championship_result, fantasy_player: player, championship: champ_a, points: 1)

      _b_result =
        insert(:championship_result, fantasy_player: player, championship: champ_b, points: 3)

      [result_a, result_b] =
        ChampionshipResult
        |> ChampionshipResult.preload_assocs_by_league(league.id)
        |> Repo.all()

      assert Enum.count(result_a.fantasy_player.roster_positions) == 1
      assert Enum.count(result_b.fantasy_player.roster_positions) == 1
    end
  end

  describe "preload_ordered_assocs_by_league/2" do
    test "returns championship results in order by points with assocs" do
      league = insert(:fantasy_league)
      insert(:championship_result, points: 8, rank: 1)
      insert(:championship_result, points: 5, rank: 2)
      insert(:championship_result, points: 3, rank: 4)
      insert(:championship_result, points: 3, rank: 3)
      insert(:championship_result, points: -1, rank: 0)

      result =
        ChampionshipResult
        |> ChampionshipResult.preload_ordered_assocs_by_league(league.id)
        |> Repo.all()

      assert Enum.map(result, & &1.rank) == [1, 2, 3, 4, 0]
    end
  end
end
