defmodule Ex338.DraftPickRepoTest do
  use Ex338.ModelCase
  alias Ex338.DraftPick

  describe "ordered_by_position/1" do
    test "returns draft picks in descending order" do
      league = insert(:fantasy_league)
      insert(:draft_pick, draft_position: 1.05, fantasy_league: league)
      insert(:draft_pick, draft_position: 1.04, fantasy_league: league)
      insert(:draft_pick, draft_position: 1.10, fantasy_league: league)

      query = DraftPick |> DraftPick.ordered_by_position
      query = from d in query, select: d.draft_position
      picks = query
              |> Repo.all
              |> Enum.map(&(Float.to_string(&1)))

      assert picks == ~w(1.04 1.05 1.1)
    end
  end
end
