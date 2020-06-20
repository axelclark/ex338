defmodule Ex338Web.CommishEmailController do
  use Ex338Web, :controller
  alias Ex338.{Repo, FantasyLeagues.FantasyLeague}
  alias Ex338Web.{CommishEmail}

  def new(conn, _params) do
    render(conn, "new.html", fantasy_leagues: Repo.all(FantasyLeague), page_title: "Commish Email")
  end

  def create(conn, %{
        "commish_email" => %{
          "leagues" => leagues,
          "subject" => subject,
          "message" => message
        }
      }) do
    result = CommishEmail.send_email_to_leagues(leagues, subject, message)

    case result do
      {:ok, _result} ->
        conn
        |> put_flash(:info, "Email sent successfully")
        |> redirect(to: Routes.commish_email_path(conn, :new))

      {:error, {_code, reason}} ->
        conn
        |> put_flash(:error, "Email failed to send: #{reason}")
        |> redirect(to: Routes.commish_email_path(conn, :new))
    end
  end
end
