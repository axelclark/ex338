defmodule Ex338.AdminCreatesFantasyLeagueTest do
  use Ex338.AcceptanceCase, async: true

  test "admin creates fantasy league", %{session: session} do
    insert_user(%{email: "test@example.com", password: "secret"})

    session
    |> visit("/admin")
    |> fill_in("Email", with: "test@example.com")
    |> fill_in("Password", with: "secret")
    |> click_on("Sign In")
    |> click_link("FantasyLeagues")
    |> click_link("New Fantasy League")
    |> find("#new_fantasyleague")
    |> fill_in("Fantasy League Name", with: "2017 Div A")
    |> fill_in("Division", with: "A")
    |> fill_in("Year", with: "2017")
    |> click_on("Create Fantasyleague")

    notice =
      session
      |> find(".alert-success")
      |> text

    assert notice =~ ~R/FantasyLeague was successfully created./
  end
end
