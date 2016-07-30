defmodule Ex338.AdminUpdatesFantasyPlayerTest do
  use Ex338.AcceptanceCase, async: true

  test "admin updatest fantasy team", %{session: session} do
    insert_user(%{email: "test@example.com", password: "secret"})
    sports_league = insert(:sports_league, league_name: "NFL")
    insert(:fantasy_player, player_name: "St Louis Rams",
                            sports_league: sports_league)

    session
    |> visit("/admin")
    |> fill_in("Email", with: "test@example.com")
    |> fill_in("Password", with: "secret")
    |> click_on("Sign In")
    |> click_link("FantasyPlayer")
    |> click_link("Edit")
    |> find("#new_fantasyplayer")
    |> fill_in("Player Name", with: "LA Rams")
    |> click_on("Update Fantasyplayer")

    notice =
      session
      |> find(".alert-success")
      |> text

    assert notice =~ ~R/FantasyPlayer was successfully updated./
  end
end
