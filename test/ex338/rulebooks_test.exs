defmodule Ex338.RulebooksTest do
  use Ex338.DataCase, async: true

  alias Ex338.Rulebooks

  describe "get_rulebook_for_fantasy_league!/2" do
    test "gets rulebook by year and draft method" do
      fantasy_league = insert(:fantasy_league, year: 2021, draft_method: "keeper")
      result = Rulebooks.get_rulebook_for_fantasy_league!(fantasy_league)

      assert result.year == 2021
      assert result.draft_method == "keeper"
    end

    test "crashes if it doesn't exist" do
      fantasy_league = insert(:fantasy_league, year: 0000, draft_method: "keeper")

      assert_raise Ex338.Rulebooks.NotFoundError, fn ->
        Rulebooks.get_rulebook_for_fantasy_league!(fantasy_league)
      end
    end
  end
end
