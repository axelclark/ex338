defmodule Ex338.User.StoreTest do
  use Ex338.DataCase
  alias Ex338.User

  describe "get_admin_emails/0" do
    test "returns all admin emails" do
      admin = insert_admin()

      result = User.Store.get_admin_emails()

      assert result == [{admin.name, admin.email}]
    end
  end

  describe "get_league_and_admin_emails/1" do
    test "returns all league and admin emails" do
      admin = insert_admin()
      user = insert(:user)
      other_user = insert(:user)
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      team_a = insert(:fantasy_team, fantasy_league: league)
      team_b = insert(:fantasy_team, fantasy_league: league)
      other_team = insert(:fantasy_team, fantasy_league: other_league)
      insert(:owner, fantasy_team: team_a, user: admin)
      insert(:owner, fantasy_team: team_b, user: user)
      insert(:owner, fantasy_team: other_team, user: other_user)

      result = User.Store.get_league_and_admin_emails(league.id)

      assert Enum.count(result) == 2
    end
  end

  describe "preload_team_by_league/2" do
    test "preloads fantasy team matching fantasy league" do
      user = insert(:user)
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      insert(:owner, fantasy_team: team, user: user)
      other_league = insert(:fantasy_league)
      other_team = insert(:fantasy_team, fantasy_league: other_league)
      insert(:owner, fantasy_team: other_team, user: user)

      result = User.Store.preload_team_by_league(user, league.id)
      %{fantasy_teams: [team_result]} = result

      assert team_result.id == team.id
    end

    test "empty list when no fantasy team in league" do
      user = insert(:user)
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      insert(:owner, fantasy_team: team, user: user)
      other_league = insert(:fantasy_league)
      _other_team = insert(:fantasy_team, fantasy_league: other_league)

      result = User.Store.preload_team_by_league(user, other_league.id)

      assert %{fantasy_teams: []} = result
    end
  end
end
