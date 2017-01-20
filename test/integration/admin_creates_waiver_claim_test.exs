defmodule Ex338.AdminCreatesWaiverTest do
  use Ex338.AcceptanceCase, async: true

  @tag integration: true
  test "admin creates waiver", %{session: session} do
    insert_admin(%{email: "test@example.com", password: "secret"})
    insert(:fantasy_player, player_name: "LA Rams")
    insert(:fantasy_player, player_name: "Oakland Raiders")
    fantasy_league = insert(:fantasy_league)
    insert(:fantasy_team, team_name: "Kintz", fantasy_league: fantasy_league)

    session
    |> visit("/admin")
    |> fill_in("Email", with: "test@example.com")
    |> fill_in("Password", with: "secret")
    |> click_on("Sign In")
    |> click_link("Waivers")
    |> click_link("New Waiver")
    |> find("#new_waiver")
    |> select("waiver_fantasy_team_id", option: "Kintz")
    |> select("waiver_status_id", option: "successful")
    |> select("waiver_add_fantasy_player_id", option: "LA Rams")
    |> select("waiver_drop_fantasy_player_id", option: "Oakland Raiders")
    |> click_on("Create Waiver")

    notice =
      session
      |> find(".alert-success")
      |> text

    assert notice =~ ~R/Waiver was successfully created./
  end
end
