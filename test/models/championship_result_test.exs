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

  describe "get_assocs_and_order_results/1" do
    test "returns championship results in order by rank with assocs" do
      insert(:championship_result, rank: 3)
      insert(:championship_result, rank: 1)
      insert(:championship_result, rank: 2)

      result = ChampionshipResult
               |> ChampionshipResult.get_assocs_and_order_results
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
