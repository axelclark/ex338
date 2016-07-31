defmodule Ex338.UserNotAuthorizedToAccessAdminTest do
  use Ex338.AcceptanceCase, async: true

  test "user not authorized to visit admin", %{session: session} do
    insert_user(%{email: "test@example.com", password: "secret"})

    session
    |> visit("/admin")
    |> fill_in("Email", with: "test@example.com")
    |> fill_in("Password", with: "secret")
    |> click_on("Sign In")

    notice =
      session
      |> find(".alert-danger")
      |> text

    assert notice =~ ~R/You are not authorized/
  end
end
