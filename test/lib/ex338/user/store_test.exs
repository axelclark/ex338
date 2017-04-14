defmodule Ex338.User.StoreTest do
  use Ex338.ModelCase
  alias Ex338.User

  describe "get_admin_emails/0" do
    test "returns all admin emails" do
      admin_a = insert_admin()

      result = User.Store.get_admin_emails

      assert result == [{admin_a.name, admin_a.email}]
    end
  end
end
