defmodule Ex338.OwnerRepoTest do
  use Ex338.ModelCase
  alias Ex338.Owner
  describe "by_league/2" do
    test "return owners from a league" do
      league_a = insert(:fantasy_league)
      league_b = insert(:fantasy_league)
      team_a = insert(:fantasy_team, team_name: "A", fantasy_league: league_a)
      team_b = insert(:fantasy_team, team_name: "B", fantasy_league: league_a)
      team_c = insert(:fantasy_team, team_name: "C", fantasy_league: league_b)
      user_a = insert_user
      user_b = insert_user
      user_c = insert_user
      insert(:owner, fantasy_team: team_a, user: user_a)
      insert(:owner, fantasy_team: team_b, user: user_b)
      insert(:owner, fantasy_team: team_c, user: user_c)


      query = Owner |> Owner.by_league(league_a.id)
      query = query |> select([o,f], f.team_name)

      assert Repo.all(query) == ~w(A B)
    end
  end

  describe "email_recipients/2" do
    test "return email addresses for a league" do
      league_a = insert(:fantasy_league)
      league_b = insert(:fantasy_league)
      team_a = insert(:fantasy_team, team_name: "A", fantasy_league: league_a)
      team_b = insert(:fantasy_team, team_name: "B", fantasy_league: league_b)
      user_a = insert_user
      user_b = insert_user
      insert(:owner, fantasy_team: team_a, user: user_a)
      insert(:owner, fantasy_team: team_b, user: user_b)


      query = Owner |> Owner.email_recipients_for_league(league_a.id)

      assert Repo.all(query) == [{user_a.name, user_a.email}]
    end
  end
end
