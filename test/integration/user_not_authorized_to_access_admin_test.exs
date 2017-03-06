defmodule Ex338.UserNotAuthorizedToAccessAdminTest do
  use Ex338.AcceptanceCase, async: true

  @tag integration: true
  test "user not authorized to visit admin", %{session: session} do
    insert_user(%{email: "test@example.com", password: "secret"})

    session
    |> visit("/admin")
    |> fill_in(Query.text_field("Email"), with: "test@example.com")
    |> fill_in(Query.text_field("Password"), with: "secret")
    |> click(Query.button("Sign In"))

    notice =
      session
      |> find(Query.css(".flash-error"))
      |> Element.text

    assert notice =~ ~R/You are not authorized/
  end
end
