defmodule Ex338.CommishEmailControllerTest do
  use Ex338.ConnCase
  import Swoosh.TestAssertions
  alias Ex338.{User, EmailTemplate}

  setup %{conn: conn} do
    user = %User{name: "test", email: "test@example.com", id: 1}
    {:ok, conn: assign(conn, :current_user, user), user: user}
  end

  describe "new/1" do
    test "renders a form to send an email", %{conn: conn} do
      conn = put_in(conn.assigns.current_user.admin, true)
      insert(:fantasy_league)

      conn = get conn, commish_email_path(conn, :new)

      assert html_response(conn, 200) =~ ~r/Send Email to League/
    end

    test "redirects to root if user is not owner", %{conn: conn} do
      insert(:fantasy_league)

      conn = get conn, commish_email_path(conn, :new)

      assert html_response(conn, 302) =~ ~r/redirected/
    end
  end

  describe "create/2" do
    test "send email with text to owners in multiple leagues", %{conn: conn} do
      conn = put_in(conn.assigns.current_user.admin, true)
      other_user = insert_user
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      insert(:owner, fantasy_team: team, user: other_user)
      subject = "Announcement"
      message = "Here is the latest info!"

      email_info = %{
        to: [{other_user.name, other_user.email}],
        cc: [],
        from: {"338 Commish", "no-reply@338admin.com"},
        subject: subject,
        message: message
      }

      attrs = %{
        leagues: [league.id],
        subject: subject,
        message: message
      }

      conn = post conn, commish_email_path(conn, :create, commish_email: attrs)

      assert html_response(conn, 302) =~ ~r/redirected/
      assert_email_sent EmailTemplate.plain_text(email_info)
    end

    test "redirects to root if user is not admin", %{conn: conn} do
      other_user = insert_user
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      insert(:owner, fantasy_team: team, user: other_user)
      subject = "Announcement"
      message = "Here is the latest info!"

      email_info = %{
        to: [{other_user.name, other_user.email}],
        cc: [],
        from: {"338 Commish", "no-reply@338admin.com"},
        subject: subject,
        message: message
      }

      attrs = %{
        leagues: [league.id],
        subject: subject,
        message: message
      }

      conn = post conn, commish_email_path(conn, :create, commish_email: attrs)

      assert html_response(conn, 302) =~ ~r/redirected/
      assert_no_email_sent
    end
  end
end
