defmodule Ex338.AdminCreatesRosterPositionTest do
  use Ex338.AcceptanceCase, async: true

  test "admin creates roster position", %{session: session} do
    insert_admin(%{email: "test@example.com", password: "secret"})
    league = insert(:sports_league)
    insert(:fantasy_player, player_name: "LA Rams", sports_league: league)
    fantasy_league = insert(:fantasy_league)
    insert(:fantasy_team, team_name: "Kintz", fantasy_league: fantasy_league)

    session
    |> visit("/admin")
    |> fill_in("Email", with: "test@example.com")
    |> fill_in("Password", with: "secret")
    |> click_on("Sign In")
    |> click_link("RosterPositions")
    |> click_link("New Roster Position")
    |> find("#new_rosterposition")
    |> select("rosterposition_position_id", option: "NFL")
    |> select("rosterposition_fantasy_player_id", option: "LA Rams")
    |> select("rosterposition_fantasy_team_id", option: "Kintz")
    |> click_on("Create Rosterposition")

    notice =
      session
      |> find(".alert-success")
      |> text

    assert notice =~ ~R/RosterPosition was successfully created./
  end
end
