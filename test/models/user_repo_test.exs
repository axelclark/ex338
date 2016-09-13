defmodule Ex338.UserRepoTest do
  use Ex338.ModelCase
  alias Ex338.User

  describe "admin_emails/0" do
    test "returns all admin emails" do
      admin_a = insert_admin

      query = User.admin_emails

      assert Repo.all(query) == [{admin_a.name, admin_a.email}]
    end
  end
end
