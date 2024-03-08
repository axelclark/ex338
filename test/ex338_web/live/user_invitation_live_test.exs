defmodule Ex338Web.UserInvitationLiveTest do
  use Ex338Web.ConnCase, async: true

  import Phoenix.LiveViewTest

  describe "New Invitations as admin" do
    setup :register_and_log_in_admin

    test "sends a new invitation email", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/invitations/new")

      new_user_email = "brown@example.com"

      view
      |> form("#invitation_form", user: %{"email" => new_user_email})
      |> render_submit() =~ "Invitation sent to #{new_user_email}"
    end
  end

  describe "New Invitations as user" do
    setup :register_and_log_in_user

    test "redirects a regular user", %{conn: conn} do
      {:error, {:redirect, %{to: "/", flash: %{"error" => "You are not authorized"}}}} =
        live(conn, ~p"/invitations/new")
    end
  end
end
