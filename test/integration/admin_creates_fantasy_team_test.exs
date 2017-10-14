defmodule Ex338Web.AdminCreatesFantasyTeamTest do
  use Ex338Web.AcceptanceCase, async: true

  @tag integration: true
  test "admin creates fantasy team", %{session: session} do
    insert_admin(%{email: "test@example.com", password: "secret"})
    insert(:fantasy_league, fantasy_league_name: "2016 Div A")

    session
    |> visit("/admin")
    |> fill_in(Query.text_field("Email"), with: "test@example.com")
    |> fill_in(Query.text_field("Password"), with: "secret")
    |> click(Query.button("Sign In"))
    |> click(Query.link("FantasyTeams"))
    |> click(Query.link("New Fantasy Team"))
    |> find(Query.css("#new_fantasy_team"))
    |> fill_in(Query.text_field("Team Name"), with: "Brown")
    |> fill_in(Query.text_field("Waiver Position"), with: "1")
    |> click(Query.option("2016 Div A"))
    |> click(Query.button("Create Fantasyteam"))

    notice =
      session
      |> find(Query.css(".alert-success"))
      |> Element.text

    assert notice =~ ~R/Fantasy Team was successfully created./
  end
end
