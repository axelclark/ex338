defmodule Ex338Web.UserController do
  use Ex338Web, :controller_html

  import Canary.Plugs

  alias Ex338.Accounts
  alias Ex338.Accounts.User
  alias Ex338Web.Authorization

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
      :edit,
      changeset: User.user_changeset(user),
      page_title: "338 Challenge",
      user: user
    )
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    render(
      conn,
      :show,
      user: user,
      page_title: "338 Challenge"
    )
  end

  def update(conn, %{"id" => id, "user" => params}) do
    user = Accounts.get_user!(id)

    case Accounts.update_user(user, params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User info updated successfully.")
        |> redirect(to: ~p"/users/#{user}")

      {:error, changeset} ->
        render(
          conn,
          :edit,
          user: user,
          page_title: "338 Challenge",
          changeset: changeset
        )
    end
  end
end
