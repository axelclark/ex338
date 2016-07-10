defmodule Ex338.CreateFantasyPlayerTest do
  use Ex338.AcceptanceCase, async: true

  test "admin creates fantasy team", %{session: session} do
     
    session
      |> visit("/admin")
      |> click_link("FantasyTeams")
      |> click_link("New Fantasy Team")
      |> find("#new_fantasyteam")
      |> fill_in("Player Team", with: "Brown")
      |> click_on("Create Fantasyteam")

    notice =
      session
      |> find(".alert-success")
      |> text

    assert notice =~ ~R/FantasyTeam was successfully created./
  end
end
