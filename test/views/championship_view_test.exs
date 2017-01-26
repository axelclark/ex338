defmodule Ex338.ChampionshipViewTest do
  use Ex338.ConnCase, async: true
  alias Ex338.{ChampionshipView}

  describe "get_team_name/1" do
    test "returns name from a fantasy team struct" do
      player =
        %{fantasy_player: %{roster_positions: [
           %{fantasy_team: %{team_name: "Brown"}}
        ]}}

      result = ChampionshipView.get_team_name(player)

      assert result == "Brown"
    end
    test "returns a dash if no positions" do
      player =
        %{fantasy_player: %{roster_positions: []}}

      result = ChampionshipView.get_team_name(player)

      assert result == "-"
    end
  end

  describe "filter_category/2" do
    test "filters list of championship by overall category" do
      championships = [
        %{name: "A", category: "overall"},
        %{name: "B", category: "overall"},
        %{name: "C", category: "event"},
        %{name: "D", category: "event"}
      ]

      results = ChampionshipView.filter_category(championships, "overall")

      assert Enum.map(results, &(&1.name)) == ~w(A B)
    end

    test "filters list of championship by event category" do
      championships = [
        %{name: "A", category: "overall"},
        %{name: "B", category: "overall"},
        %{name: "C", category: "event"},
        %{name: "D", category: "event"}
      ]

      results = ChampionshipView.filter_category(championships, "event")

      assert Enum.map(results, &(&1.name)) == ~w(C D)
    end
  end
end
