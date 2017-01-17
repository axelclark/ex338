defmodule Ex338.ChampionshipResultTest do
  use Ex338.ModelCase

  alias Ex338.ChampionshipResult

  @valid_attrs %{points: 42, rank: 42, fantasy_player_id: 2,
                 championship_id: 3}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = ChampionshipResult.changeset(%ChampionshipResult{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = ChampionshipResult.changeset(%ChampionshipResult{}, @invalid_attrs)
    refute changeset.valid?
  end

  describe "preload_assocs_and_order_results/1" do
    test "returns championship results in order by rank with assocs" do
      insert(:championship_result, rank: 3)
      insert(:championship_result, rank: 1)
      insert(:championship_result, rank: 2)

      result = ChampionshipResult
               |> ChampionshipResult.preload_assocs_and_order_results
               |> Repo.all

      assert Enum.map(result, &(&1.rank)) == [1, 2, 3]
    end
  end

  describe "preload_ordered_assocs_by_league/2" do
    test "returns championship results in order by rank with assocs" do
      league = insert(:fantasy_league)
      insert(:championship_result, rank: 3)
      insert(:championship_result, rank: 1)
      insert(:championship_result, rank: 2)

      result = ChampionshipResult
               |> ChampionshipResult.preload_ordered_assocs_by_league(league.id)
               |> Repo.all

      assert Enum.map(result, &(&1.rank)) == [1, 2, 3]
    end
  end

  describe "order_by_rank/1" do
    test "returns championship results in order by rank" do
      insert(:championship_result, rank: 3)
      insert(:championship_result, rank: 1)
      insert(:championship_result, rank: 2)

      query = ChampionshipResult |> ChampionshipResult.order_by_rank
      query = from c in query, select: c.rank

      assert Repo.all(query) == [1, 2, 3]
    end
  end

  describe "preload_assocs/1" do
    test "returns any associated fantasy players" do
      player = insert(:fantasy_player)
      insert(:championship_result, fantasy_player: player)

      result = ChampionshipResult
               |> ChampionshipResult.preload_assocs
               |> Repo.one

      assert result.fantasy_player.id == player.id
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
      _other_pos = insert(:roster_position, fantasy_team: team_b,
                                            fantasy_player: player_a)
      insert(:championship_result, fantasy_player: player_a)

      [%{fantasy_player: %{roster_positions: [position]}}] =
        ChampionshipResult
        |> ChampionshipResult.preload_assocs_by_league(f_league_a.id)
        |> Repo.all

      assert position.id == pos.id
      assert position.fantasy_team.id == team_a.id
    end
  end

  describe "only_overall/1" do
    test "returns all championships" do
      overall = insert(:championship, category: "overall")
      event   = insert(:championship, category: "event")
      overall_result = insert(:championship_result, championship: overall)
      insert(:championship_result, championship: event)

      result = ChampionshipResult
               |> ChampionshipResult.only_overall
               |> Repo.one

      assert result.id == overall_result.id
    end
  end
end
