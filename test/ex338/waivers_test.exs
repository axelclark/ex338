defmodule Ex338.WaiversTest do
  use Ex338.DataCase, async: true

  alias Ex338.{Waivers.Waiver, Waivers, CalendarAssistant, RosterPositions.RosterPosition}

  describe "create_waiver" do
    test "creates a waiver" do
      league = insert(:fantasy_league)
      sports_league = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sports_league)

      insert(
        :championship,
        sports_league: sports_league,
        waiver_deadline_at: CalendarAssistant.days_from_now(1),
        championship_at: CalendarAssistant.days_from_now(9)
      )

      player_b = insert(:fantasy_player, sports_league: sports_league)
      team = insert(:fantasy_team, fantasy_league: league)
      player_a = insert(:fantasy_player, sports_league: sports_league)
      insert(:roster_position, fantasy_player: player_a, fantasy_team: team)
      attrs = %{drop_fantasy_player_id: player_a.id, add_fantasy_player_id: player_b.id}

      Waivers.create_waiver(team, attrs)
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

      position =
        insert(
          :roster_position,
          fantasy_player: player_a,
          fantasy_team: team
        )

      insert(
        :championship,
        sports_league: sports_league,
        waiver_deadline_at: CalendarAssistant.days_from_now(1),
        championship_at: CalendarAssistant.days_from_now(9)
      )

      attrs = %{drop_fantasy_player_id: player_a.id}

      {:ok, result} = Waivers.create_waiver(team, attrs)
      position = Repo.get!(RosterPosition, position.id)

      assert result.fantasy_team_id == team.id
      assert result.status == "successful"
      assert position.status == "dropped"
    end
  end

  describe "find/1" do
    test "returns a waivers with assocs" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      owner = insert(:owner, fantasy_team: team)
      sport = insert(:sports_league)
      add_player = insert(:fantasy_player, sports_league: sport)
      drop_player = insert(:fantasy_player, sports_league: sport)

      waiver =
        insert(
          :waiver,
          fantasy_team: team,
          add_fantasy_player: add_player,
          drop_fantasy_player: drop_player
        )

      result = Waivers.find_waiver(waiver.id)

      [owner_result] = result.fantasy_team.owners

      assert owner_result.id == owner.id
      assert result.drop_fantasy_player.sports_league.id == sport.id
      assert result.add_fantasy_player.sports_league.id == sport.id
      assert result.fantasy_team.fantasy_league.id == league.id
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

      result = Waivers.get_all_waivers(league.id)

      assert Enum.count(result) == 2
    end
  end

  describe "get_all_pending_waivers/0" do
    test "returns all pending waivers with assocs" do
      ready = CalendarAssistant.days_from_now(-2)
      still_open = CalendarAssistant.days_from_now(2)
      insert_list(2, :waiver, status: "pending", process_at: ready)
      insert_list(2, :waiver, status: "successful", process_at: ready)
      insert(:waiver, process_at: still_open)

      result = Waivers.get_all_pending_waivers()

      assert Enum.count(result) == 2
    end
  end

  describe "batch_process_all/0" do
    test "processes all pending waivers sorted by waiver position & league" do
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      team_a = insert(:fantasy_team, fantasy_league: league, waiver_position: 2)
      team_b = insert(:fantasy_team, fantasy_league: league, waiver_position: 1)
      team_c = insert(:fantasy_team, fantasy_league: other_league, waiver_position: 6)

      sport = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sport)
      insert(:league_sport, fantasy_league: other_league, sports_league: sport)

      player_a = insert(:fantasy_player, sports_league: sport)
      player_b = insert(:fantasy_player, sports_league: sport)
      player_c = insert(:fantasy_player, sports_league: sport)

      insert(:roster_position, fantasy_player: player_a, fantasy_team: team_a)
      insert(:roster_position, fantasy_player: player_b, fantasy_team: team_b)
      insert(:roster_position, fantasy_player: player_a, fantasy_team: team_c)

      process_at1 = CalendarAssistant.days_from_now(-4)
      process_at2 = CalendarAssistant.days_from_now(-3)

      insert(
        :waiver,
        fantasy_team: team_a,
        add_fantasy_player: player_c,
        drop_fantasy_player: player_a,
        process_at: process_at1
      )

      insert(
        :waiver,
        fantasy_team: team_b,
        add_fantasy_player: player_c,
        drop_fantasy_player: player_b,
        process_at: process_at1
      )

      insert(
        :waiver,
        fantasy_team: team_c,
        add_fantasy_player: player_c,
        drop_fantasy_player: player_a,
        process_at: process_at2
      )

      :ok = Waivers.batch_process_all()

      [w1, w2, w3] =
        Waiver
        |> Repo.all()
        |> Enum.sort(&(&1.id <= &2.id))

      [r1, r2, r3, r4, r5] =
        RosterPosition
        |> Repo.all()
        |> Enum.sort(&(&1.id <= &2.id))

      assert w1.status == "unsuccessful"
      assert w2.status == "successful"
      assert w3.status == "successful"

      assert r1.status == "active"
      assert r2.status == "dropped"
      assert r3.status == "dropped"
      assert r4.status == "active"
      assert r5.status == "active"
      assert r4.fantasy_team_id == team_b.id
      assert r5.fantasy_team_id == team_c.id
    end

    test "handles when dropped player is no longer owned" do
      league = insert(:fantasy_league)
      team_a = insert(:fantasy_team, fantasy_league: league, waiver_position: 1)

      sport = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sport)
      player_a = insert(:fantasy_player, sports_league: sport)
      player_b = insert(:fantasy_player, sports_league: sport)
      player_c = insert(:fantasy_player, sports_league: sport)

      insert(:roster_position, fantasy_player: player_a, fantasy_team: team_a)

      waiver1 = CalendarAssistant.days_from_now(-4)
      waiver2 = CalendarAssistant.days_from_now(-3)

      insert(
        :waiver,
        fantasy_team: team_a,
        add_fantasy_player: player_b,
        drop_fantasy_player: player_a,
        process_at: waiver1
      )

      insert(
        :waiver,
        fantasy_team: team_a,
        add_fantasy_player: player_c,
        drop_fantasy_player: player_a,
        process_at: waiver2
      )

      :ok = Waivers.batch_process_all()

      [w1, w2] =
        Waiver
        |> Repo.all()
        |> Enum.sort(&(&1.id <= &2.id))

      [r1, r2] =
        RosterPosition
        |> Repo.all()
        |> Enum.sort(&(&1.id <= &2.id))

      assert w1.status == "successful"
      assert w2.status == "invalid"

      assert r1.status == "dropped"
      assert r2.status == "active"
    end

    test "processes pending waiver updating the waiver positions" do
      league = insert(:fantasy_league)
      team_a = insert(:fantasy_team, fantasy_league: league, waiver_position: 2)
      team_b = insert(:fantasy_team, fantasy_league: league, waiver_position: 3)
      insert(:fantasy_team, fantasy_league: league, waiver_position: 1)
      insert(:fantasy_team, fantasy_league: league, waiver_position: 4)

      sport = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sport)
      player_a = insert(:fantasy_player, sports_league: sport)
      player_b = insert(:fantasy_player, sports_league: sport)
      player_c = insert(:fantasy_player, sports_league: sport)
      player_d = insert(:fantasy_player, sports_league: sport)
      player_e = insert(:fantasy_player, sports_league: sport)

      insert(:roster_position, fantasy_player: player_a, fantasy_team: team_a)
      insert(:roster_position, fantasy_player: player_b, fantasy_team: team_b)
      insert(:roster_position, fantasy_player: player_e, fantasy_team: team_a)

      waiver1 = CalendarAssistant.days_from_now(-4)
      waiver2 = CalendarAssistant.days_from_now(-3)

      insert(
        :waiver,
        fantasy_team: team_a,
        add_fantasy_player: player_c,
        drop_fantasy_player: player_a,
        process_at: waiver1
      )

      insert(
        :waiver,
        fantasy_team: team_b,
        add_fantasy_player: player_c,
        drop_fantasy_player: player_b,
        process_at: waiver1
      )

      insert(
        :waiver,
        fantasy_team: team_a,
        add_fantasy_player: player_d,
        drop_fantasy_player: player_e,
        process_at: waiver2
      )

      insert(
        :waiver,
        fantasy_team: team_b,
        add_fantasy_player: player_d,
        drop_fantasy_player: player_b,
        process_at: waiver2
      )

      :ok = Waivers.batch_process_all()

      [w1, w2, w3, w4] =
        Waiver
        |> Repo.all()
        |> Enum.sort(&(&1.id <= &2.id))

      [r1, r2, r3, r4, r5] =
        RosterPosition
        |> Repo.all()
        |> Enum.sort(&(&1.id <= &2.id))

      assert w1.status == "successful"
      assert w2.status == "unsuccessful"
      assert w3.status == "unsuccessful"
      assert w4.status == "successful"

      assert r1.status == "dropped"
      assert r2.status == "dropped"
      assert r3.status == "active"
      assert r4.status == "active"
      assert r5.status == "active"
      assert r4.fantasy_team_id == team_a.id
      assert r5.fantasy_team_id == team_b.id
      assert r4.acq_method == "waiver"
      assert r5.acq_method == "waiver"
    end

    test "doesn't process if process_at in future" do
      league = insert(:fantasy_league)
      team_a = insert(:fantasy_team, fantasy_league: league, waiver_position: 1)

      sport = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sport)
      player_a = insert(:fantasy_player, sports_league: sport)
      player_b = insert(:fantasy_player, sports_league: sport)

      insert(:roster_position, fantasy_player: player_a, fantasy_team: team_a)

      waiver1 = CalendarAssistant.days_from_now(4)

      insert(
        :waiver,
        fantasy_team: team_a,
        add_fantasy_player: player_b,
        drop_fantasy_player: player_a,
        process_at: waiver1
      )

      :ok = Waivers.batch_process_all()

      w1 = Repo.one(Waiver)
      r1 = Repo.one(RosterPosition)

      assert w1.status == "pending"
      assert r1.status == "active"
    end
  end
end
