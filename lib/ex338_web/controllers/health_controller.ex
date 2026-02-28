defmodule Ex338Web.HealthController do
  use Ex338Web, :controller

  def index(conn, _params) do
    Ecto.Adapters.SQL.query!(Ex338.Repo, "SELECT 1")

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "ok")
  end
end
