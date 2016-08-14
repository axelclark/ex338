defmodule Ex338.NotificationEmail do
  import Swoosh.Email

  def draft_update(draft_pick) do
    new
    |> to({"Axel", "axelclark2@yahoo.com"})
    |> from({"Axel", "no-reply@338admin.com"})
    |> subject("Draft Pick Update")
    |> html_body("<h1>#{draft_pick.fantasy_team.team_name} picks #{draft_pick.fantasy_player.player_name}</h1>")
    |> text_body("#{draft_pick.fantasy_team.team_name} picks #{draft_pick.fantasy_player.player_name}\n")
  end
end
