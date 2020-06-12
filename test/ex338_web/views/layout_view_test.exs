defmodule Ex338Web.LayoutViewTest do
  use Ex338Web.ConnCase, async: true

  alias Ex338Web.LayoutView
  alias Ex338.{FantasyLeagues.FantasyLeague}

  @leagues [
    %FantasyLeague{
      id: 6,
      navbar_display: :primary,
      draft_method: :keeper,
      division: "B",
      year: 2018
    },
    %FantasyLeague{
      id: 5,
      navbar_display: :hidden,
      draft_method: :redraft,
      division: "NA",
      year: 2019
    },
    %FantasyLeague{
      id: 4,
      navbar_display: :primary,
      draft_method: :redraft,
      division: "A",
      year: 2019
    },
    %FantasyLeague{
      id: 3,
      navbar_display: :primary,
      draft_method: :redraft,
      division: "A",
      year: 2018
    },
    %FantasyLeague{
      id: 2,
      navbar_display: :primary,
      draft_method: :redraft,
      division: "B",
      year: 2018
    },
    %FantasyLeague{
      id: 1,
      navbar_display: :archived,
      draft_method: :redraft,
      division: "A",
      year: 2017
    }
  ]

  describe "display/2" do
    test "returns primary leagues for navbar display with default to redraft" do
      result = LayoutView.display(@leagues, :primary)

      assert Enum.map(result, & &1.id) == [4, 3, 2]
    end

    test "returns primary leagues for navbar display" do
      [result] = LayoutView.display(@leagues, :primary, :keeper)

      assert result.id == 6
    end

    test "returns archived leagues for navbar display" do
      [result] = LayoutView.display(@leagues, :archived)

      assert result.id == 1
    end
  end
end
