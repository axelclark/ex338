defmodule Ex338.CommishEmail do
  @moduledoc false
  alias Ex338.{Owner, User, EmailTemplate, Mailer, Repo}

  def send_email_to_leagues(leagues, subject, message) do
    owners = Owner.get_leagues_email_addresses(leagues)
    admins = Repo.all(User.admin_emails)
    recipients = unique_recipients(owners, admins)

    email_info =
      %{
        to: recipients,
        cc: [],
        from: {"338 Commish", "no-reply@338admin.com"},
        subject: subject,
        message: message
      }

    email_info
    |> EmailTemplate.plain_text
    |> Mailer.deliver
  end

  def unique_recipients(owners, admins) do
    Enum.uniq(owners ++ admins)
  end
end