defmodule Ex338Web.CommishEmailController do
  use Ex338Web, :controller_html

  alias Ex338.FantasyLeagues.FantasyLeague
  alias Ex338.Repo
  alias Ex338Web.CommishNotifier

  def new(conn, _params) do
    render(
      conn,
      :new,
      fantasy_leagues: Repo.all(FantasyLeague),
      page_title: "Commish Email"
    )
  end

  def create(conn, %{
        "commish_email" => %{"leagues" => leagues, "subject" => subject, "message" => message}
      }) do
    result = CommishNotifier.send_email_to_leagues(leagues, subject, message)

    case result do
      {:ok, _result} ->
        conn
        |> put_flash(:info, "Email sent successfully")
        |> redirect(to: ~p"/commish_email/new")

      {:error, reason} ->
        conn
        |> put_flash(:error, "Email failed to send: #{reason}")
        |> redirect(to: ~p"/commish_email/new")
    end
  end
end
