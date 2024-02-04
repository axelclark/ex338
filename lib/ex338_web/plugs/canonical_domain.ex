defmodule Ex338Web.CanonicalDomain do
  @moduledoc """
  Redirects to root domain when host is heroku domain.
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

  defp redirect?(%{host: "the338challenge.herokuapp.com"}), do: true

  defp redirect?(_), do: false

  defp canonical_host do
    Ex338Web.Endpoint.config(:url)[:host]
  end
end
