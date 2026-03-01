defmodule Ex338Web.Api.V1.FallbackController do
  use Ex338Web, :controller

  alias Ex338Web.Api.V1.ErrorJSON

  def call(conn, nil) do
    conn
    |> put_status(:not_found)
    |> put_view(json: ErrorJSON)
    |> render(:error, message: "Not found")
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(json: ErrorJSON)
    |> render(:error, message: "Not found")
  end
end
