defmodule Ex338.User.StoreTest do
  use Ex338.DataCase
  alias Ex338.User

  describe "get_admin_emails/0" do
    test "returns all admin emails" do
      admin = insert_admin()

      result = User.Store.get_admin_emails

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
end
