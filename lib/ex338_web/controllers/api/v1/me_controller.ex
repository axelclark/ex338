defmodule Ex338Web.Api.V1.MeController do
  use Ex338Web, :controller

  alias Ex338.Accounts

  action_fallback Ex338Web.Api.V1.FallbackController

  @doc """
  Returns the authenticated user with the teams they own. Lets a client confirm
  its API token is valid, learn whether it has admin scope, and map the user's
  teams to the ids every team-scoped endpoint needs.
  """
  def show(conn, _params) do
    user = Accounts.load_user_teams(conn.assigns.current_user)
    render(conn, :show, user: user)
  end
end
