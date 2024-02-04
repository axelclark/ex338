defmodule Ex338.CommishEmailTest do
  use Ex338.DataCase, async: true

  import Swoosh.TestAssertions

  alias Ex338Web.CommishEmail
  alias Ex338Web.EmailTemplate

  describe "send_email_to_leagues/3" do
    test "sends an email to owners of a list of leagues" do
      admin_user = insert_admin()
      other_user = insert_user()
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

      CommishEmail.send_email_to_leagues(
        [league.id],
        subject,
        message
      )

      assert_email_sent(EmailTemplate.plain_text(email_info))
    end
  end

  describe "unique_recipients/2" do
    test "combines admins and owners" do
      admins = [{"Ryan", "ryan@example.com"}]
      owners = [{"owner", "owner@example.com"}]

      result = CommishEmail.unique_recipients(owners, admins)

      assert result == owners ++ admins
    end

    test "combines admins and owners while removing duplicates" do
      brown = {"Ryan", "ryan@example.com"}
      owners = [brown, {"owner", "owner@example.com"}]
      admins = [brown]

      result = CommishEmail.unique_recipients(owners, admins)

      assert result == owners
    end
  end
end
