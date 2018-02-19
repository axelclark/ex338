defmodule Ex338.WaiverTest do
  use Ex338.DataCase, async: true

  alias Ex338.{Waiver, FantasyTeam, CalendarAssistant}
  import Ecto.Changeset

  describe "build_new_changeset" do
    test "builds a new_changeset from a fantasy team struct" do
      team = %FantasyTeam{id: 1}

      changeset = Waiver.build_new_changeset(team)

      assert changeset.data.fantasy_team_id == team.id
    end
  end

  describe "by_league/2" do
    test "returns waivers in a fantasy league" do
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      other_team = insert(:fantasy_team, fantasy_league: other_league)
      insert(:waiver, fantasy_team: team)
      insert(:waiver, fantasy_team: other_team)

      query =
        Waiver
        |> Waiver.by_league(league.id)
        |> select([w], w.fantasy_team_id)

      assert Repo.one(query) == team.id
    end
  end

  describe "changeset/2" do
    test "valid with minimum attributes" do
      attrs = %{fantasy_team_id: 1, status: "pending"}

      changeset = Waiver.changeset(%Waiver{}, attrs)

      assert changeset.valid?
    end

    test "valid with valid attributes" do
      team = insert(:fantasy_team)
      player = insert(:fantasy_player)
      new_player = insert(:fantasy_player)
      insert(:roster_position, fantasy_team: team, fantasy_player: player)
      waiver =
        insert(
          :waiver,
          fantasy_team: team,
          drop_fantasy_player: player,
          add_fantasy_player: new_player
        )
      attrs = %{status: "successful"}

      changeset = Waiver.changeset(waiver, attrs)

      assert changeset.valid?
    end

    test "invalid if roster position not active" do
      team = insert(:fantasy_team)
      player = insert(:fantasy_player)
      new_player = insert(:fantasy_player)
      insert(
        :roster_position,
        fantasy_team: team,
        fantasy_player: player,
        status: "dropped"
      )
      waiver =
        insert(
          :waiver,
          fantasy_team: team,
          drop_fantasy_player: player,
          add_fantasy_player: new_player
        )
      attrs = %{status: "successful"}

      changeset = Waiver.changeset(waiver, attrs)

      refute changeset.valid?
    end

    test "invalid with incorrect status" do
      attrs = %{fantasy_team_id: 1, status: "Pending"}

      changeset = Waiver.changeset(%Waiver{}, attrs)

      refute changeset.valid?
    end

    @invalid_attrs %{}
    test "error with invalid attributes" do
      changeset = Waiver.changeset(%Waiver{}, @invalid_attrs)
      refute changeset.valid?
    end

    test "valid with six flex spots in use" do
      tm = insert(:fantasy_team)
      [drop | regular_slots] = insert_list(4, :roster_position, fantasy_team: tm)

      flex_sport = List.first(regular_slots).fantasy_player.sports_league

      [add | plyrs] = insert_list(6, :fantasy_player, sports_league: flex_sport)

      _flex_slots =
        for plyr <- plyrs do
          insert(:roster_position, fantasy_team: tm, fantasy_player: plyr)
        end

      attrs =
        %{
          fantasy_team_id: tm.id,
          drop_fantasy_player_id: drop.fantasy_player_id,
          add_fantasy_player_id: add.id,
        }

      changeset = Waiver.changeset(%Waiver{}, attrs)

      assert changeset.valid?
    end

    test "error if too many flex spots in use" do
      tm = insert(:fantasy_team)
      [drop | regular_slots] = insert_list(4, :roster_position, fantasy_team: tm)

      flex_sport = List.first(regular_slots).fantasy_player.sports_league

      [add | plyrs] = insert_list(7, :fantasy_player, sports_league: flex_sport)

      _flex_slots =
        for plyr <- plyrs do
          insert(:roster_position, fantasy_team: tm, fantasy_player: plyr)
        end

      attrs =
        %{
          fantasy_team_id: tm.id,
          drop_fantasy_player_id: drop.fantasy_player_id,
          add_fantasy_player_id: add.id,
        }

      changeset = Waiver.changeset(%Waiver{}, attrs)

      refute changeset.valid?
    end
  end

  describe "new_changeset/2" do
    test "valid with valid attributes" do
      league = insert(:fantasy_league)
      sports_league = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sports_league)
      insert(:championship, sports_league: sports_league,
        waiver_deadline_at: CalendarAssistant.days_from_now(1),
        championship_at:    CalendarAssistant.days_from_now(9))
      player = insert(:fantasy_player, sports_league: sports_league)
      team = insert(:fantasy_team, fantasy_league: league)
      attrs = %{fantasy_team_id: team.id, add_fantasy_player_id: player.id}

      changeset = Waiver.new_changeset(%Waiver{}, attrs)
      assert changeset.valid?
    end

    test "error without a fantasy team or an add or a drop" do
      changeset = Waiver.new_changeset(%Waiver{}, @invalid_attrs)

      refute changeset.valid?
      assert changeset.errors == [
        drop_fantasy_player_id: {"Must submit an add or a drop", []},
        add_fantasy_player_id: {"Must submit an add or a drop", []},
        fantasy_team_id: {"can't be blank", [validation: :required]}]
      assert changeset.constraints ==
        [%{constraint: "waivers_add_fantasy_player_id_fkey",
          error: {"does not exist", []}, field: :add_fantasy_player_id,
          match: :exact, type: :foreign_key},
        %{constraint: "waivers_drop_fantasy_player_id_fkey",
          error: {"does not exist", []}, field: :drop_fantasy_player_id,
          match: :exact, type: :foreign_key},
        %{constraint: "waivers_fantasy_team_id_fkey",
          error: {"does not exist", []}, field: :fantasy_team_id,
          match: :exact, type: :foreign_key}]
    end

    test "sets process_at 3 days from now if no waiver for player existing" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      player = insert(:fantasy_player)
      three_days_from_now = CalendarAssistant.days_from_now(3)
      attrs = %{fantasy_team_id: team.id, add_fantasy_player_id: player.id}

      changeset = Waiver.new_changeset(%Waiver{}, attrs)

      process_at = get_field(changeset, :process_at)
      assert DateTime.diff(process_at, three_days_from_now) < 1
    end

    test "sets process_at waiver deadline if in blind waiver period" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      sport = insert(:sports_league, hide_waivers: true)
      insert(:league_sport, fantasy_league: league, sports_league: sport)
      deadline = CalendarAssistant.days_from_now(7)
      insert(:championship,
        waiver_deadline_at: deadline,
        category: "overall",
        sports_league: sport,
        championship_at: CalendarAssistant.days_from_now(19)
      )
      player = insert(:fantasy_player, sports_league: sport)
      attrs = %{fantasy_team_id: team.id, add_fantasy_player_id: player.id}

      changeset = Waiver.new_changeset(%Waiver{}, attrs)

      assert get_field(changeset, :process_at) == deadline
    end


    test "process_at matches existing if already a pending waiver for a player" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      other_team = insert(:fantasy_team, fantasy_league: league)
      player = insert(:fantasy_player)
      two_days_from_now = CalendarAssistant.days_from_now(2)
      insert(:waiver, fantasy_team: other_team, add_fantasy_player: player,
                      status: "pending",
                      process_at:  two_days_from_now
      )
     attrs = %{fantasy_team_id: team.id, add_fantasy_player_id: player.id}

     changeset = Waiver.new_changeset(%Waiver{}, attrs)

     assert get_field(changeset, :process_at) == two_days_from_now
    end


    test "sets process_at to now if just dropping a player" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      player = insert(:fantasy_player)
      now = DateTime.utc_now()
      attrs = %{fantasy_team_id: team.id, drop_fantasy_player_id: player.id}

      changeset = Waiver.new_changeset(%Waiver{}, attrs)

      process_at = get_field(changeset, :process_at)
      assert DateTime.diff(process_at, now) < 1
    end

    test "error if submitted after existing wait period ends"do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      sports_league = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sports_league)
      insert(:championship, sports_league: sports_league,
        waiver_deadline_at: CalendarAssistant.days_from_now(1),
        championship_at:    CalendarAssistant.days_from_now(9))
      other_team = insert(:fantasy_team, fantasy_league: league)
      player = insert(:fantasy_player, sports_league: sports_league)
      insert(:waiver, fantasy_team: other_team, add_fantasy_player: player,
                      status: "pending",
                      process_at: CalendarAssistant.days_from_now(-3)
      )
      attrs = %{fantasy_team_id: team.id, add_fantasy_player_id: player.id,
                process_at: DateTime.utc_now}

      changeset = Waiver.new_changeset(%Waiver{}, attrs)

      refute changeset.valid?
      assert changeset.errors == [
        drop_fantasy_player_id: {"Wait period has ended.", []},
        add_fantasy_player_id:
          {"Wait period has ended on another claim for this player.", []}
      ]
    end

    test "valid if submitted before existing wait period ends"do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      sports_league = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sports_league)
      insert(:championship, sports_league: sports_league,
        waiver_deadline_at: CalendarAssistant.days_from_now(1),
        championship_at:    CalendarAssistant.days_from_now(9))
      other_team = insert(:fantasy_team, fantasy_league: league)
      player = insert(:fantasy_player, sports_league: sports_league)
      insert(:waiver, fantasy_team: other_team, add_fantasy_player: player,
                      status: "pending",
                      process_at:  CalendarAssistant.days_from_now(3)
      )
      attrs = %{
        fantasy_team_id: team.id,
        add_fantasy_player_id: player.id,
        process_at: DateTime.utc_now()
      }

      changeset = Waiver.new_changeset(%Waiver{}, attrs)

      assert changeset.valid?
    end

    test "error if add only waiver and no open position" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      insert_list(20, :roster_position, fantasy_team: team)
      insert(:roster_position, fantasy_team: team, status: "dropped")
      sports_league = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sports_league)
      insert(:championship, sports_league: sports_league,
        waiver_deadline_at: CalendarAssistant.days_from_now(1),
        championship_at:    CalendarAssistant.days_from_now(9))
      player = insert(:fantasy_player, sports_league: sports_league)
      attrs = %{fantasy_team_id: team.id, add_fantasy_player_id: player.id}

      changeset = Waiver.new_changeset(%Waiver{}, attrs)

      refute changeset.valid?
      assert changeset.errors == [
        drop_fantasy_player_id:
          {"No open position, must submit a player to drop", []}
      ]
    end

    test "no error if roster is full and a player is dropped" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      insert_list(20, :roster_position, fantasy_team: team)
      sports_league = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sports_league)

      insert(:championship, sports_league: sports_league,
        waiver_deadline_at: CalendarAssistant.days_from_now(1),
        championship_at:    CalendarAssistant.days_from_now(9))
      player = insert(:fantasy_player, sports_league: sports_league)
      drop_player = insert(:fantasy_player, sports_league: sports_league)
      attrs = %{fantasy_team_id: team.id, add_fantasy_player_id: player.id,
                drop_fantasy_player_id: drop_player.id}

      changeset = Waiver.new_changeset(%Waiver{}, attrs)

      assert changeset.valid?
    end

    test "error on add if sports league overall waiver deadline has passed" do
      league = insert(:fantasy_league)
      sports_league = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sports_league)
      insert(:championship, sports_league: sports_league, category: "overall",
        waiver_deadline_at: CalendarAssistant.days_from_now(-1),
        championship_at:    CalendarAssistant.days_from_now(9))
      player = insert(:fantasy_player, sports_league: sports_league)
      team = insert(:fantasy_team, fantasy_league: league)
      attrs = %{fantasy_team_id: team.id, add_fantasy_player_id: player.id}

      changeset = Waiver.new_changeset(%Waiver{}, attrs)

      refute changeset.valid?
      assert changeset.errors == [
        add_fantasy_player_id:
          {"Claim submitted after waiver deadline.", []}
      ]
    end

    test "error on add if sports league championship is in the past" do
      league = insert(:fantasy_league)
      sports_league = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sports_league)
      insert(:championship, sports_league: sports_league, category: "overall",
        waiver_deadline_at: CalendarAssistant.days_from_now(-17),
        championship_at:    CalendarAssistant.days_from_now(-9))
      player = insert(:fantasy_player, sports_league: sports_league)
      team = insert(:fantasy_team, fantasy_league: league)
      attrs = %{fantasy_team_id: team.id, add_fantasy_player_id: player.id}

      changeset = Waiver.new_changeset(%Waiver{}, attrs)

      refute changeset.valid?
      assert changeset.errors == [
        add_fantasy_player_id:
          {"Claim submitted after season ended.", []}
      ]
    end

    test "error on add if no sports league championship" do
      league = insert(:sports_league)
      player = insert(:fantasy_player, sports_league: league)
      team = insert(:fantasy_team)
      attrs = %{fantasy_team_id: team.id, add_fantasy_player_id: player.id}

      changeset = Waiver.new_changeset(%Waiver{}, attrs)

      refute changeset.valid?
      assert changeset.errors == [
        add_fantasy_player_id:
          {"Claim submitted after season ended.", []}
      ]
    end

    test "error on drop if sports league overall waiver deadline has passed" do
      league = insert(:fantasy_league)
      sports_league = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sports_league)
      insert(:championship, sports_league: sports_league, category: "overall",
        waiver_deadline_at: CalendarAssistant.days_from_now(-1),
        championship_at:    CalendarAssistant.days_from_now(9))
      player = insert(:fantasy_player, sports_league: sports_league)
      team = insert(:fantasy_team, fantasy_league: league)
      attrs = %{fantasy_team_id: team.id, drop_fantasy_player_id: player.id}

      changeset = Waiver.new_changeset(%Waiver{}, attrs)

      refute changeset.valid?
      assert changeset.errors == [
        drop_fantasy_player_id:
          {"Claim submitted after waiver deadline.", []}
      ]
    end

    test "error on drop if sports league championship is in the past" do
      league = insert(:fantasy_league)
      sports_league = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sports_league)
      insert(:championship, sports_league: sports_league, category: "overall",
        waiver_deadline_at: CalendarAssistant.days_from_now(-17),
        championship_at:    CalendarAssistant.days_from_now(-9))
      player = insert(:fantasy_player, sports_league: sports_league)
      team = insert(:fantasy_team, fantasy_league: league)
      attrs = %{fantasy_team_id: team.id, drop_fantasy_player_id: player.id}

      changeset = Waiver.new_changeset(%Waiver{}, attrs)

      refute changeset.valid?
      assert changeset.errors == [
        drop_fantasy_player_id:
          {"Claim submitted after season ended.", []}
      ]
    end

    test "error on drop if no sports league championship" do
      league = insert(:sports_league)
      player = insert(:fantasy_player, sports_league: league)
      team = insert(:fantasy_team)
      attrs = %{fantasy_team_id: team.id, drop_fantasy_player_id: player.id}

      changeset = Waiver.new_changeset(%Waiver{}, attrs)

      refute changeset.valid?
      assert changeset.errors == [
        drop_fantasy_player_id:
          {"Claim submitted after season ended.", []}
      ]
    end
  end

  describe "pending/1" do
    test "returns pending waivers" do
      pending = insert(:waiver, status: "pending")
      insert(:waiver, status: "successful")

      result =
        Waiver
        |> Waiver.pending
        |> Repo.one

      assert result.id == pending.id
    end
  end

  describe "ready_to_process/1" do
    test "returns waivers with process date in past" do
      ready = insert(:waiver, process_at: CalendarAssistant.days_from_now(-1))
      insert(:waiver, process_at: CalendarAssistant.days_from_now(1))

      result =
        Waiver
        |> Waiver.ready_to_process
        |> Repo.one

      assert result.id == ready.id
    end
  end

  describe "pending_waivers_for_player/2" do
    test "returns pending waivers for a player in a fantasy league" do
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      other_team = insert(:fantasy_team, fantasy_league: other_league)
      player = insert(:fantasy_player)
      insert(:waiver, fantasy_team: team, add_fantasy_player: player,
                      status: "pending")
      insert(:waiver, fantasy_team: other_team, add_fantasy_player: player,
                      status: "pending")

      query = Waiver.pending_waivers_for_player(Waiver, player.id, league.id)
      query = from w in query, select: w.fantasy_team_id

      assert Repo.all(query) == [team.id]
    end
  end

  describe "preload_assocs/1" do
    test "preload all waiver assocs" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      owner = insert(:owner, fantasy_team: team)
      sport = insert(:sports_league)
      add_player = insert(:fantasy_player, sports_league: sport)
      drop_player = insert(:fantasy_player, sports_league: sport)
      insert(
        :waiver,
        fantasy_team: team,
        add_fantasy_player: add_player,
        drop_fantasy_player: drop_player
      )

      result =
        Waiver
        |> Waiver.preload_assocs()
        |> Repo.one()
      [owner_result] = result.fantasy_team.owners

      assert owner_result.id == owner.id
      assert result.drop_fantasy_player.sports_league.id == sport.id
      assert result.add_fantasy_player.sports_league.id == sport.id
    end
  end

  describe "update_changeset" do
    test "casts only a player to drop" do
      waiver = insert(:waiver, process_at: CalendarAssistant.days_from_now(3))
      attrs = %{drop_fantasy_player_id: 1, add_fantasy_player_id: 2,
                status: "successful"}

      changeset = Waiver.update_changeset(waiver, attrs)

      assert changeset.valid?
      assert changeset.changes == %{drop_fantasy_player_id: 1}
    end

    test "invalid if submitted after wait period ends" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      sports_league = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sports_league)

      insert(:championship, sports_league: sports_league,
        waiver_deadline_at: CalendarAssistant.days_from_now(1),
        championship_at:    CalendarAssistant.days_from_now(9))
      player = insert(:fantasy_player)
      other_player = insert(:fantasy_player)
      new_player = insert(:fantasy_player, sports_league: sports_league)
      waiver = insert(:waiver, fantasy_team: team, add_fantasy_player: player,
                      drop_fantasy_player: other_player, status: "pending",
                      process_at: CalendarAssistant.days_from_now(-9)
      )
      attrs = %{drop_fantasy_player_id: new_player.id}

      changeset = Waiver.update_changeset(waiver, attrs)

      refute changeset.valid?
      assert changeset.errors == [
        drop_fantasy_player_id: {"Wait period has ended.", []},
        add_fantasy_player_id:
          {"Wait period has ended on another claim for this player.", []}
      ]
    end
  end
end
