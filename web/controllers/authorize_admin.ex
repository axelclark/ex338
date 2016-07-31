defmodule Ex338.AuthorizeAdmin do
  import Plug.Conn
  import Phoenix.Controller
  alias Ex338.User

  def authorize_admin(conn, _opts) do
    user = conn.assigns.current_user
    conn |> check_authorized(user)
  end

  defp check_authorized(conn, %User{admin: true}) do
    conn
  end

  defp check_authorized(conn, _) do
    conn
    |> put_flash(:error, "You are not authorized")
    |> redirect(to: "/")
    |> halt
  end
end
