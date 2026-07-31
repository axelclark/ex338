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
  alias Ex338.Accounts.User
  alias Ex338.Accounts.UserToken

  def init(options), do: options

  def call(conn, _opts) do
    with {:ok, token} <- fetch_bearer_token(conn),
         %UserToken{user: %User{} = user} = api_token <- Accounts.get_api_token(token) do
      conn
      |> assign(:current_user, user)
      |> assign(:current_api_token, api_token)
    else
      _ -> unauthorized(conn)
    end
  end

  # RFC 7235 defines the auth scheme as case-insensitive, so compare it that way
  # instead of pattern-matching the literal "Bearer ".
  defp fetch_bearer_token(conn) do
    with [header | _] <- get_req_header(conn, "authorization"),
         [scheme, token] <- String.split(header, " ", parts: 2),
         "bearer" <- String.downcase(scheme),
         token when token != "" <- String.trim(token) do
      {:ok, token}
    else
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
