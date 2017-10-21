defmodule Ex338.UserRepoTest do
  use Ex338.DataCase
  alias Ex338.{User, FantasyLeague}

  describe "admin_emails/0" do
    test "returns all admin emails" do
      admin_a = insert_admin()

      query = User.admin_emails

      assert Repo.all(query) == [{admin_a.name, admin_a.email}]
    end
  end

  describe "my_fantasy_league/1" do
    test "returns newest fantasy leageu for a user" do
      league_1 = insert(:fantasy_league, year: 2016)
      league_2 = insert(:fantasy_league, year: 2017)
      team_a   = insert(:fantasy_team, fantasy_league: league_1)
      team_b   = insert(:fantasy_team, fantasy_league: league_2)
      user   = insert_user()
      insert(:owner, fantasy_team: team_a, user: user)
      insert(:owner, fantasy_team: team_b, user: user)

      query = User.my_fantasy_league(user)
      %FantasyLeague{id: id} =  Repo.one(query)

      assert id == league_2.id
    end
  end
end
