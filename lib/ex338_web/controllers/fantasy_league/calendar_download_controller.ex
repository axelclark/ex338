defmodule Ex338Web.FantasyLeague.CalendarDownloadController do
  use Ex338Web, :controller

  alias Ex338.FantasyLeagues

  def show(conn, %{"fantasy_league_id" => fantasy_league_id}) do
    calendar = FantasyLeagues.generate_calendar(fantasy_league_id)

    send_download(
      conn,
      {:binary, calendar},
      content_type: "text/calendar",
      filename: "338_calendar.ics"
    )
  end
end
