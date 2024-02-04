defmodule Ex338Web.Authorization do
  @moduledoc false

  import Phoenix.Controller
  import Plug.Conn

  alias Ex338.Accounts.User

  def authorize_admin(conn, _opts) do
    user = conn.assigns.current_user
    check_authorized(conn, user)
  end

  defp check_authorized(conn, %User{admin: true}) do
    conn
  end

  defp check_authorized(conn, _) do
    conn
    |> put_flash(:error, "You are not authorized")
    |> redirect(to: "/")
    |> halt()
  end

  def handle_unauthorized(conn) do
    conn
    |> put_flash(:error, "You can't access that page!")
    |> redirect(to: "/")
    |> halt()
  end
end
