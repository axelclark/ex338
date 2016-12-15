defmodule Ex338.CommishEmailTest do
  use Ex338.ModelCase
  import Swoosh.TestAssertions
  alias Ex338.{EmailTemplate, CommishEmail}

  describe "send_email_to_leagues/3" do
    test "sends an email to owners of a list of leagues" do
      admin_user = insert_admin
      other_user = insert_user
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      insert(:owner, fantasy_team: team, user: other_user)
      subject = "Announcement"
      message = "Here is the latest info!"

      email_info = %{
        to: [{other_user.name, other_user.email}],
        cc: [{admin_user.name, admin_user.email}],
        from: {"338 Commish", "no-reply@338admin.com"},
        subject: subject,
        message: message
      }

      CommishEmail.send_email_to_leagues(
        [league.id],
        subject,
        message
      )

      assert_email_sent EmailTemplate.plain_text(email_info)
    end
  end
end
