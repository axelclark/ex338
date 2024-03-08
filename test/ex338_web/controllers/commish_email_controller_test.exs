defmodule Ex338Web.CommishEmailControllerTest do
  use Ex338Web.ConnCase

  import Swoosh.TestAssertions

  alias Ex338Web.NotifierTemplate

  describe "new/1 as admin" do
    setup :register_and_log_in_admin

    test "renders a form to send an email", %{conn: conn} do
      insert(:fantasy_league)

      conn = get(conn, ~p"/commish_email/new")

      assert html_response(conn, 200) =~ ~r/Send an email to fantasy leagues/
    end
  end

  describe "new/1 as user" do
    setup :register_and_log_in_user

    test "redirects to root if user is not owner", %{conn: conn} do
      insert(:fantasy_league)

      conn = get(conn, ~p"/commish_email/new")

      assert html_response(conn, 302) =~ ~r/redirected/
    end
  end

  describe "create/2 as admin" do
    setup :register_and_log_in_admin

    test "send email with text to owners in multiple leagues", %{conn: conn, user: admin_user} do
      other_user = insert(:user)
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      insert(:owner, fantasy_team: team, user: other_user)
      subject = "Announcement"
      message = "Here is the latest info!"

      email_info = %{
        bcc: [{other_user.name, other_user.email}, {admin_user.name, admin_user.email}],
        cc: {"338 Commish", "commish@the338challenge.com"},
        from: {"338 Commish", "commish@the338challenge.com"},
        subject: subject,
        message: message
      }

      attrs = %{
        leagues: [league.id],
        subject: subject,
        message: message
      }

      conn = post(conn, ~p"/commish_email?#{[commish_email: attrs]}")

      assert html_response(conn, 302) =~ ~r/redirected/
      assert_email_sent(NotifierTemplate.plain_text(email_info))
    end
  end

  describe "create/2 as user" do
    setup :register_and_log_in_user

    test "redirects to root if user is not admin", %{conn: conn} do
      other_user = insert_user()
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      insert(:owner, fantasy_team: team, user: other_user)
      subject = "Announcement"
      message = "Here is the latest info!"

      attrs = %{
        leagues: [league.id],
        subject: subject,
        message: message
      }

      conn = post(conn, ~p"/commish_email?#{[commish_email: attrs]}")

      assert html_response(conn, 302) =~ ~r/redirected/
      assert_no_email_sent()
    end
  end
end
