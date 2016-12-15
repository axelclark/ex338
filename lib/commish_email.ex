defmodule Ex338.CommishEmail do
  @moduledoc false
  alias Ex338.{Owner, User, EmailTemplate, Mailer, Repo}

  def send_email_to_leagues(leagues, subject, message) do
    email_info =
      %{
        to: Owner.get_leagues_email_addresses(leagues),
        cc: Repo.all(User.admin_emails),
        from: {"338 Commish", "no-reply@338admin.com"},
        subject: subject,
        message: message
      }

    email_info
    |> EmailTemplate.plain_text
    |> Mailer.deliver
  end
end
