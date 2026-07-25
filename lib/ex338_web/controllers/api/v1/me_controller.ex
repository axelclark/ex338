defmodule Ex338Web.Api.V1.MeController do
  use Ex338Web, :controller

  action_fallback Ex338Web.Api.V1.FallbackController

  @doc """
  Returns the authenticated user. Lets a client confirm its API token is valid
  and learn whether it has admin scope.
  """
  def show(conn, _params) do
    render(conn, :show, user: conn.assigns.current_user)
  end
end
