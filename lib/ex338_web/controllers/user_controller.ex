defmodule Ex338Web.UserController do
  use Ex338Web, :controller

  alias Ex338.{User}
  alias Ex338Web.{Authorization}

  import Canary.Plugs

  plug(
    :load_and_authorize_resource,
    model: User,
    only: [:edit, :update],
    preload: [owners: :fantasy_team],
    unauthorized_handler: {Authorization, :handle_unauthorized}
  )

  def edit(conn, %{"id" => _id}) do
    user = conn.assigns.user

    render(
      conn,
      "edit.html",
      changeset: User.user_changeset(user),
      user: user
    )
  end

  def show(conn, %{"id" => id}) do
    user = User.Store.get_user!(id)

    render(
      conn,
      "show.html",
      user: user
    )
  end

  def update(conn, %{"id" => id, "user" => params}) do
    user = User.Store.get_user!(id)

    case User.Store.update_user(user, params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User info updated successfully.")
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, changeset} ->
        render(
          conn,
          "edit.html",
          user: user,
          changeset: changeset
        )
    end
  end
end
