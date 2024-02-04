defmodule Ex338Web.CommishEmail do
  @moduledoc false
  alias Ex338.Accounts.User
  alias Ex338.FantasyTeams
  alias Ex338.Repo
  alias Ex338Web.EmailTemplate
  alias Ex338Web.Mailer

  def send_email_to_leagues(leagues, subject, message) do
    owners = FantasyTeams.get_leagues_email_addresses(leagues)
    admins = Repo.all(User.admin_emails())
    recipients = unique_recipients(owners, admins)
    default_admin = Mailer.default_from_name_and_email()

    email_info = %{
      cc: default_admin,
      from: default_admin,
      subject: subject,
      message: message
    }

    recipients
    |> batch_by_aws_max_recipients()
    |> Enum.map(fn recipients ->
      email_info
      |> Map.put(:bcc, recipients)
      |> EmailTemplate.plain_text()
      |> Mailer.deliver()
      |> Mailer.handle_delivery()
    end)
    |> parse_results()
  end

  def unique_recipients(owners, admins) do
    Enum.uniq(owners ++ admins)
  end

  defp batch_by_aws_max_recipients(recipients) do
    Enum.chunk_every(recipients, 40)
  end

  defp parse_results(results) do
    Enum.reduce_while(results, {:ok, "commish emails sent"}, &parse_result/2)
  end

  defp parse_result({:ok, _result}, success_message) do
    {:cont, success_message}
  end

  defp parse_result({:error, _message} = error, _success_message) do
    {:halt, error}
  end
end
