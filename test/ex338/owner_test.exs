defmodule Ex338.OwnerTest do
  use Ex338.DataCase, async: true

  alias Ex338.Owner

  @valid_attrs %{fantasy_team_id: 1, user_id: 1}
  @invalid_attrs %{}

  describe "changeset/2" do
    test "valid attributes" do
      changeset = Owner.changeset(%Owner{}, @valid_attrs)
      assert changeset.valid?
    end

    test "invalid attributes" do
      changeset = Owner.changeset(%Owner{}, @invalid_attrs)
      refute changeset.valid?
    end
  end

  describe "by_league/2" do
    test "return owners from a league" do
      league_a = insert(:fantasy_league)
      league_b = insert(:fantasy_league)
      team_a = insert(:fantasy_team, team_name: "A", fantasy_league: league_a)
      team_b = insert(:fantasy_team, team_name: "B", fantasy_league: league_a)
      team_c = insert(:fantasy_team, team_name: "C", fantasy_league: league_b)
      user_a = insert_user()
      user_b = insert_user()
      user_c = insert_user()
      insert(:owner, fantasy_team: team_a, user: user_a)
      insert(:owner, fantasy_team: team_b, user: user_b)
      insert(:owner, fantasy_team: team_c, user: user_c)

      query = Owner.by_league(Owner, league_a.id)
      query = select(query, [o, f], f.team_name)

      assert Repo.all(query) == ~w(A B)
    end
  end

  describe "email_recipients/2" do
    test "return email addresses for a league" do
      league_a = insert(:fantasy_league)
      league_b = insert(:fantasy_league)
      team_a = insert(:fantasy_team, team_name: "A", fantasy_league: league_a)
      team_b = insert(:fantasy_team, team_name: "B", fantasy_league: league_b)
      user_a = insert_user()
      user_b = insert_user()
      insert(:owner, fantasy_team: team_a, user: user_a)
      insert(:owner, fantasy_team: team_b, user: user_b)

      query = Owner.email_recipients_for_league(Owner, league_a.id)

      assert Repo.all(query) == [{user_a.name, user_a.email}]
    end
  end
end
