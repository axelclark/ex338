defmodule Ex338.UserRepoTest do
  use Ex338.DataCase
  alias Ex338.{User}

  describe "admin_emails/0" do
    test "returns all admin emails" do
      admin_a = insert_admin()

      query = User.admin_emails

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
        |> User.alphabetical
        |> Repo.all
        |> Enum.map(&(&1.name))

      assert result == ["A", "B", "C"]
    end
  end
end
