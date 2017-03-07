defmodule Ex338.WaiverTest do
  use Ex338.ModelCase, async: true

  alias Ex338.{Waiver, CalendarAssistant, RosterPosition}
  import Ecto.Changeset

  @invalid_attrs %{}

  describe "build_new_changeset" do
    test "builds a new_changeset from a fantasy team struct" do
      team = insert(:fantasy_team)

      changeset = Waiver.build_new_changeset(team)

      assert changeset.data.fantasy_team_id == team.id
    end
  end

  describe "changeset/2" do
    test "valid with valid attributes" do
      league = insert(:sports_league)
      insert(:championship, sports_league: league,
        waiver_deadline_at: CalendarAssistant.days_from_now(1),
        championship_at:    CalendarAssistant.days_from_now(9))
      player = insert(:fantasy_player, sports_league: league)
      attrs = %{fantasy_team_id: 1, add_fantasy_player_id: player.id}

      changeset = Waiver.changeset(%Waiver{}, attrs)

      assert changeset.valid?
    end

    test "error with invalid attributes" do
      changeset = Waiver.changeset(%Waiver{}, @invalid_attrs)
      refute changeset.valid?
    end
  end

  describe "new_changeset/2" do
    test "valid with valid attributes" do
      league = insert(:sports_league)
      insert(:championship, sports_league: league,
        waiver_deadline_at: CalendarAssistant.days_from_now(1),
        championship_at:    CalendarAssistant.days_from_now(9))
      player = insert(:fantasy_player, sports_league: league)
      team = insert(:fantasy_team)
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

      assert get_field(changeset, :process_at) == three_days_from_now
    end

    test "sets process_at waiver deadline if in blind waiver period" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      sport = insert(:sports_league, hide_waivers: true)
      deadline = CalendarAssistant.days_from_now(7)
      championship = insert(:championship,
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
      now = Ecto.DateTime.utc
      attrs = %{fantasy_team_id: team.id, drop_fantasy_player_id: player.id}

      changeset = Waiver.new_changeset(%Waiver{}, attrs)

      assert get_field(changeset, :process_at) == now
    end

    test "error if submitted after existing wait period ends"do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      sports_league = insert(:sports_league)
      insert(:championship, sports_league: sports_league,
        waiver_deadline_at: CalendarAssistant.days_from_now(1),
        championship_at:    CalendarAssistant.days_from_now(9))
      other_team = insert(:fantasy_team, fantasy_league: league)
      player = insert(:fantasy_player, sports_league: sports_league)
      insert(:waiver, fantasy_team: other_team, add_fantasy_player: player,
                      status: "pending",
                      process_at: Ecto.DateTime.cast!(
                        %{day: 7, hour: 14, min: 0, month: 10, sec: 0, year: 2016}
      ))
      attrs = %{fantasy_team_id: team.id, add_fantasy_player_id: player.id,
                process_at: Ecto.DateTime.utc}

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
      insert(:championship, sports_league: sports_league,
        waiver_deadline_at: CalendarAssistant.days_from_now(1),
        championship_at:    CalendarAssistant.days_from_now(9))
      other_team = insert(:fantasy_team, fantasy_league: league)
      player = insert(:fantasy_player, sports_league: sports_league)
      insert(:waiver, fantasy_team: other_team, add_fantasy_player: player,
                      status: "pending",
                      process_at:  CalendarAssistant.days_from_now(3)
      )
      attrs = %{fantasy_team_id: team.id, add_fantasy_player_id: player.id,
               process_at: Ecto.DateTime.utc}

      changeset = Waiver.new_changeset(%Waiver{}, attrs)

      assert changeset.valid?
    end

    test "error if add only waiver and no open position" do
      team = insert(:fantasy_team)
      insert_list(20, :roster_position, fantasy_team: team)
      insert(:roster_position, fantasy_team: team, status: "dropped")
      sports_league = insert(:sports_league)
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
      team = insert(:fantasy_team)
      insert_list(20, :roster_position, fantasy_team: team)
      sports_league = insert(:sports_league)
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
      league = insert(:sports_league)
      insert(:championship, sports_league: league, category: "overall",
        waiver_deadline_at: CalendarAssistant.days_from_now(-1),
        championship_at:    CalendarAssistant.days_from_now(9))
      player = insert(:fantasy_player, sports_league: league)
      team = insert(:fantasy_team)
      attrs = %{fantasy_team_id: team.id, add_fantasy_player_id: player.id}

      changeset = Waiver.new_changeset(%Waiver{}, attrs)

      refute changeset.valid?
      assert changeset.errors == [
        add_fantasy_player_id:
          {"Claim submitted after waiver deadline.", []}
      ]
    end

    test "error on add if sports league championship is in the past" do
      league = insert(:sports_league)
      insert(:championship, sports_league: league, category: "overall",
        waiver_deadline_at: CalendarAssistant.days_from_now(-17),
        championship_at:    CalendarAssistant.days_from_now(-9))
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
      league = insert(:sports_league)
      insert(:championship, sports_league: league, category: "overall",
        waiver_deadline_at: CalendarAssistant.days_from_now(-1),
        championship_at:    CalendarAssistant.days_from_now(9))
      player = insert(:fantasy_player, sports_league: league)
      team = insert(:fantasy_team)
      attrs = %{fantasy_team_id: team.id, drop_fantasy_player_id: player.id}

      changeset = Waiver.new_changeset(%Waiver{}, attrs)

      refute changeset.valid?
      assert changeset.errors == [
        drop_fantasy_player_id:
          {"Claim submitted after waiver deadline.", []}
      ]
    end

    test "error on drop if sports league championship is in the past" do
      league = insert(:sports_league)
      insert(:championship, sports_league: league, category: "overall",
        waiver_deadline_at: CalendarAssistant.days_from_now(-17),
        championship_at:    CalendarAssistant.days_from_now(-9))
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
      insert(:championship, sports_league: sports_league,
        waiver_deadline_at: CalendarAssistant.days_from_now(1),
        championship_at:    CalendarAssistant.days_from_now(9))
      player = insert(:fantasy_player)
      other_player = insert(:fantasy_player)
      new_player = insert(:fantasy_player, sports_league: sports_league)
      waiver = insert(:waiver, fantasy_team: team, add_fantasy_player: player,
                      drop_fantasy_player: other_player, status: "pending",
                      process_at: Ecto.DateTime.cast!(
                        %{day: 7, hour: 14, min: 0, month: 10, sec: 0, year: 2016}
      ))
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

  describe "create_waiver" do
    test "creates a waiver" do
      league = insert(:sports_league)
      insert(:championship, sports_league: league,
        waiver_deadline_at: CalendarAssistant.days_from_now(1),
        championship_at:    CalendarAssistant.days_from_now(9))
      player_b = insert(:fantasy_player, sports_league: league)
      team = insert(:fantasy_team)
      player_a = insert(:fantasy_player, sports_league: league)
      insert(:roster_position, fantasy_player: player_a, fantasy_team: team)
      attrs = %{drop_fantasy_player_id: player_a.id,
                add_fantasy_player_id: player_b.id}

      Waiver.create_waiver(team, attrs)
      waiver = Repo.get_by!(Waiver, attrs)

      assert waiver.fantasy_team_id == team.id
      assert waiver.status == "pending"
    end

    test "drop only waiver is processed immediately" do
      team = insert(:fantasy_team)
      sports_league = insert(:sports_league)
      player_a = insert(:fantasy_player, sports_league: sports_league)
      position = insert(:roster_position, fantasy_player: player_a,
                                          fantasy_team: team)
      insert(:championship, sports_league: sports_league,
        waiver_deadline_at: CalendarAssistant.days_from_now(1),
        championship_at:    CalendarAssistant.days_from_now(9))
      attrs = %{drop_fantasy_player_id: player_a.id}

      {:ok, result} = Waiver.create_waiver(team, attrs)
      position = Repo.get!(RosterPosition, position.id)

      assert result.fantasy_team_id == team.id
      assert result.status == "successful"
      assert position.status == "dropped"
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

      result = Waiver.get_all_waivers(league.id)

      assert Enum.count(result) == 2
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

      query = Waiver |> Waiver.by_league(league.id)
      query = from w in query, select: w.fantasy_team_id

      assert Repo.all(query) == [team.id]
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
end
