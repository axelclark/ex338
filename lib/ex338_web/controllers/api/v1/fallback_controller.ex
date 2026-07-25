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

  def call(conn, {:error, :forbidden}) do
    conn
    |> put_status(:forbidden)
    |> put_view(json: ErrorJSON)
    |> render(:error, message: "You are not authorized to perform this action")
  end

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: ErrorJSON)
    |> render(:changeset_error, changeset: changeset)
  end
end
