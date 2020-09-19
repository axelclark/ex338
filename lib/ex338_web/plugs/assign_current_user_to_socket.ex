defmodule Ex338Web.AssignCurrentUserToSocket do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _params) do
    user = Pow.Plug.current_user(conn)

    conn
    |> put_session(:current_user_id, user.id)
    |> assign(:current_user, user)
  end
end
