defmodule Ex338Web.Mailer do
  @moduledoc false
  use Swoosh.Mailer, otp_app: :ex338

  require Logger

  def handle_delivery({:ok, result}) do
    Logger.info("Sent email notification")
    {:ok, result}
  end

  def handle_delivery({:error, {_, reason}}) do
    Logger.error("Email failed to send: #{inspect(reason)}")
    {:error, reason}
  end

  def build_and_deliver(recipient, subject, body) do
    email =
      Swoosh.Email.new(
        to: recipient,
        from: default_from_name_and_email(),
        subject: subject,
        html_body:
          body
          |> Phoenix.HTML.html_escape()
          |> Phoenix.HTML.safe_to_string()
      )

    case deliver(email) do
      {:ok, _} ->
        Logger.info("Sent email notification")
        {:ok, email}

      {:error, reason} ->
        Logger.warning("Sending email failed: #{inspect(reason)}")
        {:error, reason}
    end
  end

  def default_from_name_and_email do
    email_address = Application.fetch_env!(:ex338, :mailer_default_from_email)
    name = Application.fetch_env!(:ex338, :mailer_default_from_name)

    {name, email_address}
  end
end
