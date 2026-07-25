defmodule Ex338Web.Plugs.ApiAuth do
  @moduledoc """
  Authenticates API and MCP requests via a personal access token.

  Reads a bearer token from the `Authorization: Bearer <token>` header, looks up
  the owning user, and assigns it to `:current_user`. Responds with a 401 JSON
  error when the header is missing or the token is invalid or expired.

  Authorization (which teams/actions a user may touch) is handled downstream by
  `Ex338.Abilities`, exactly as in the HTML layer — this plug only establishes
  identity.
  """
  import Phoenix.Controller
  import Plug.Conn

  alias Ex338.Accounts

  def init(options), do: options

  def call(conn, _opts) do
    with {:ok, token} <- fetch_bearer_token(conn),
         %Accounts.User{} = user <- Accounts.get_user_by_api_token(token) do
      assign(conn, :current_user, user)
    else
      _ -> unauthorized(conn)
    end
  end

  defp fetch_bearer_token(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token | _] -> {:ok, String.trim(token)}
      _ -> :error
    end
  end

  defp unauthorized(conn) do
    conn
    |> put_status(:unauthorized)
    |> put_view(Ex338Web.Api.V1.ErrorJSON)
    |> render(:error, message: "Invalid or missing API token")
    |> halt()
  end
end
