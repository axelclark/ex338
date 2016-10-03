defmodule Ex338.WaiverTest do
  use Ex338.ModelCase, async: true

  alias Ex338.Waiver

  @valid_attrs %{fantasy_team_id: 1}
  @invalid_attrs %{}

  describe "changeset/2" do
    test "changeset with valid attributes" do
      changeset = Waiver.changeset(%Waiver{}, @valid_attrs)
      assert changeset.valid?
    end

    test "changeset with invalid attributes" do
      changeset = Waiver.changeset(%Waiver{}, @invalid_attrs)
      refute changeset.valid?
    end
  end

  describe "new_changeset/2" do
    test "changeset with valid attributes" do
      changeset = Waiver.new_changeset(%Waiver{}, @valid_attrs)
      assert changeset.valid?
    end

    test "changeset with invalid attributes" do
      changeset = Waiver.new_changeset(%Waiver{}, @invalid_attrs)
      refute changeset.valid?
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

      query = Waiver.pending_waivers_for_player(player.id, league.id)
      query = from w in query, select: w.fantasy_team_id

      assert Repo.all(query) == [team.id]
    end
  end
end
