defmodule Ex338.UserTest do
  use Ex338.DataCase
  alias Ex338.{User}

  describe "admin_emails/0" do
    test "returns all admin emails" do
      admin_a = insert_admin()

      query = User.admin_emails()

      assert Repo.all(query) == [{admin_a.name, admin_a.email}]
    end
  end

  describe "alphabetical/1" do
    test "returns users in alphabetical order by name" do
      insert(:user, name: "B")
      insert(:user, name: "A")
      insert(:user, name: "C")

      result =
        User
        |> User.alphabetical()
        |> Repo.all()
        |> Enum.map(& &1.name)

      assert result == ["A", "B", "C"]
    end
  end

  describe "preload_assocs/1" do
    test "preloads assocs for a user" do
      user = insert(:user)
      team = insert(:fantasy_team)
      insert(:owner, user: user, fantasy_team: team)

      %{owners: [owner_result]} =
        User
        |> User.preload_assocs()
        |> Repo.one()

      assert owner_result.fantasy_team.id == team.id
    end
  end

  describe "user_changeset/2" do
    @valid_attrs %{email: "axel@example.com"}
    test "changeset with valid attributes" do
      changeset = User.user_changeset(%User{name: "A", email: "j@me.com"}, @valid_attrs)
      assert changeset.valid?
    end

    @invalid_attrs %{email: "j"}
    test "changeset with invalid attributes" do
      changeset = User.user_changeset(%User{name: "A", email: "j@me.com"}, @invalid_attrs)
      refute changeset.valid?
    end

    @extra_attrs %{admin: true}
    test "doesn't allow updates to unauthorized fields" do
      changeset = User.user_changeset(%User{name: "A", email: "j@me.com"}, @extra_attrs)
      assert changeset.changes == %{}
    end
  end
end
