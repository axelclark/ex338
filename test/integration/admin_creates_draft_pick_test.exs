defmodule Ex338.AdminCreatesDraftPickTest do
  use Ex338.AcceptanceCase, async: true

  @tag integration: true
  test "admin creates draft pick", %{session: session} do

    insert_admin(%{email: "test@example.com", password: "secret"})
    insert(:fantasy_player, player_name: "LA Rams")
    fantasy_league = insert(:fantasy_league, fantasy_league_name: "2016 Div A")
    insert(:fantasy_team, team_name: "Kintz", fantasy_league: fantasy_league)

    session
    |> visit("/admin")
    |> fill_in("Email", with: "test@example.com")
    |> fill_in("Password", with: "secret")
    |> click_on("Sign In")
    |> click_link("DraftPicks")
    |> click_link("New Draft Pick")
    |> find("#new_draftpick")
    |> fill_in("Draft Position", with: "1.01")
    |> select("draftpick_fantasy_league_id", option: "2016 Div A")
    |> select("draftpick_fantasy_team_id", option: "Kintz")
    |> select("draftpick_fantasy_player_id", option: "LA Rams")
    |> click_on("Create Draftpick")

    notice =
      session
      |> find(".alert-success")
      |> text

    assert notice =~ ~R/DraftPick was successfully created./
  end
end
