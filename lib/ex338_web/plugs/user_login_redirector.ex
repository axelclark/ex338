defmodule Ex338Web.Plugs.UserLoginRedirector do
  @moduledoc false
  use Phoenix.VerifiedRoutes, endpoint: Ex338Web.Endpoint, router: Ex338Web.Router

  def init(default), do: default

  def call(conn, _opts) do
    conn
    |> Phoenix.Controller.redirect(to: ~p"/users/log_in")
    |> Plug.Conn.halt()
  end
end
