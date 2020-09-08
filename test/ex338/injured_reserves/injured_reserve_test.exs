defmodule Ex338.InjuredReserves.InjuredReserveTest do
  use Ex338.DataCase, async: true

  alias Ex338.{InjuredReserves.InjuredReserve}

  describe "by_league/2" do
    test "returns injured reserve actions in a fantasy league" do
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      other_team = insert(:fantasy_team, fantasy_league: other_league)
      insert(:injured_reserve, fantasy_team: team)
      insert(:injured_reserve, fantasy_team: other_team)

      query = InjuredReserve.by_league(InjuredReserve, league.id)
      query = from(i in query, select: i.fantasy_team_id)

      assert Repo.all(query) == [team.id]
    end
  end

  describe "changeset/2" do
    @valid_attrs %{fantasy_team_id: 1, status: "pending"}
    test "with valid attributes" do
      changeset = InjuredReserve.changeset(%InjuredReserve{}, @valid_attrs)
      assert changeset.valid?
    end

    @invalid_attrs %{}
    test "with invalid attributes" do
      changeset = InjuredReserve.changeset(%InjuredReserve{}, @invalid_attrs)
      refute changeset.valid?
    end

    @invalid_attrs %{fantasy_team_id: 1, status: "Pending"}
    test "with invalid status" do
      changeset = InjuredReserve.changeset(%InjuredReserve{}, @invalid_attrs)
      refute changeset.valid?
    end
  end

  describe "preload_assocs/1" do
    test "returns the user with assocs for a given id" do
      team = insert(:fantasy_team)
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)

      ir =
        insert(
          :injured_reserve,
          injured_player: player_a,
          fantasy_team: team,
          replacement_player: player_b
        )

      result =
        InjuredReserve
        |> InjuredReserve.preload_assocs()
        |> Repo.one()

      assert result.id == ir.id
      assert result.injured_player.id == player_a.id
      assert result.replacement_player.id == player_b.id
      assert result.fantasy_team.id == team.id
    end
  end
end
