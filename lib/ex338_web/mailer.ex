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

  def default_from_name_and_email() do
    email_address = Application.fetch_env!(:ex338, :mailer_default_from_email)
    name = Application.fetch_env!(:ex338, :mailer_default_from_name)

    {name, email_address}
  end
end
