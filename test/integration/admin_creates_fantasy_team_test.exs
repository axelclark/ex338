defmodule Ex338.AdminCreatesFantasyTeamTest do
  use Ex338.AcceptanceCase, async: true

  test "admin creates fantasy team", %{session: session} do
    insert(:fantasy_league, fantasy_league_name: "2016 Div A")
     
    session
      |> visit("/admin")
      |> click_link("FantasyTeams")
      |> click_link("New Fantasy Team")
      |> find("#new_fantasyteam")
      |> fill_in("Team Name", with: "Brown")
      |> fill_in("Waiver Position", with: "1")
      |> select("fantasyteam_fantasy_league_id", option: "2016 Div A")
      |> click_on("Create Fantasyteam")

    notice =
      session
      |> find(".alert-success")
      |> text

    assert notice =~ ~R/FantasyTeam was successfully created./
  end
end
