defmodule Ex338.WaiverTest do
  use Ex338.ModelCase, async: true

  alias Ex338.{Waiver, CalendarAssistant, RosterPosition}
  import Ecto.Changeset

  @valid_attrs %{fantasy_team_id: 1, add_fantasy_player_id: 2}
  @invalid_attrs %{}

  describe "changeset/2" do
    test "valid with valid attributes" do
      changeset = Waiver.changeset(%Waiver{}, @valid_attrs)
      assert changeset.valid?
    end

    test "error with invalid attributes" do
      changeset = Waiver.changeset(%Waiver{}, @invalid_attrs)
      refute changeset.valid?
    end
  end

  describe "new_changeset/2" do
    test "valid with valid attributes" do
      team = insert(:fantasy_team)
      attrs = %{fantasy_team_id: team.id, add_fantasy_player_id: 2}

      changeset = Waiver.new_changeset(%Waiver{}, attrs)
      assert changeset.valid?
    end

    test "error without a fantasy team or an add or a drop " do
      changeset = Waiver.new_changeset(%Waiver{}, @invalid_attrs)

      refute changeset.valid?
      assert changeset.errors == [
        drop_fantasy_player_id: {"Must submit an add or a drop", []},
        add_fantasy_player_id: {"Must submit an add or a drop", []},
        fantasy_team_id: {"can't be blank", []}]
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
      other_team = insert(:fantasy_team, fantasy_league: league)
      player = insert(:fantasy_player)
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
        add_fantasy_player_id: {"Existing waiver and wait period has already ended.", []}
      ]
    end

    test "valid if submitted before existing wait period ends"do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      other_team = insert(:fantasy_team, fantasy_league: league)
      player = insert(:fantasy_player)
      insert(:waiver, fantasy_team: other_team, add_fantasy_player: player,
                      status: "pending",
                      process_at:  CalendarAssistant.days_from_now(3)
      )
     attrs = %{fantasy_team_id: team.id, add_fantasy_player_id: player.id,
               process_at: Ecto.DateTime.utc}

     changeset = Waiver.new_changeset(%Waiver{}, attrs)

     assert changeset.valid?
    end
  end

  describe "create_waiver" do
    test "creates a waiver" do
      team = insert(:fantasy_team)
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)
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
      player_a = insert(:fantasy_player)
      position = insert(:roster_position, fantasy_player: player_a,
                                          fantasy_team: team)
      attrs = %{drop_fantasy_player_id: player_a.id}

      {:ok, result} = Waiver.create_waiver(team, attrs)
      position = Repo.get!(RosterPosition, position.id)

      assert result.fantasy_team_id == team.id
      assert result.status == "successful"
      assert position.status == "dropped"
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
