defmodule Ex338Web.CanonicalDomain do
  @moduledoc """
  Redirects to canonical domain when host is a platform domain (e.g. Render).
  """

  import Plug.Conn

  def init(options) do
    # initialize options

    options
  end

  def call(conn, _opts) do
    uri =
      conn
      |> request_url()
      |> URI.parse()

    if redirect?(uri) do
      uri = %{uri | host: canonical_host()}
      canonical_url = URI.to_string(uri)

      conn
      |> put_status(:moved_permanently)
      |> Phoenix.Controller.redirect(external: canonical_url)
      |> halt()
    else
      conn
    end
  end

  defp redirect?(%{host: "ex338.onrender.com"}), do: true

  defp redirect?(_), do: false

  defp canonical_host do
    Ex338Web.Endpoint.config(:url)[:host]
  end
end
