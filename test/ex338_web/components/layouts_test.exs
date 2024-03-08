defmodule Ex338Web.LayoutsTest do
  use Ex338Web.ConnCase, async: true

  alias Ex338.FantasyLeagues.FantasyLeague
  alias Ex338Web.Layouts

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
      result = Layouts.display(@leagues, :primary)

      assert Enum.map(result, & &1.id) == [4, 3, 2]
    end

    test "returns primary leagues for navbar display" do
      [result] = Layouts.display(@leagues, :primary, :keeper)

      assert result.id == 6
    end

    test "returns archived leagues for navbar display" do
      [result] = Layouts.display(@leagues, :archived)

      assert result.id == 1
    end
  end

  describe "show_nav_components?/1" do
    test "returns true if the navbar and sidebar should displayed", %{conn: conn} do
      conn = get(conn, "/")
      assert Layouts.show_nav_components?(conn)
    end

    test "returns false for the login page", %{conn: conn} do
      conn = get(conn, ~p"/users/log_in")
      refute Layouts.show_nav_components?(conn)
    end
  end
end
