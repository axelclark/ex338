defmodule Ex338Web.Mailer do
  @moduledoc false
  use Swoosh.Mailer, otp_app: :ex338

  require Logger

  def handle_delivery({:ok, result}) do
    Logger.info("Sent email notification")
    {:ok, result}
  end

  def handle_delivery({:error, {_, reason}}) do
    Logger.error("Email failed to send: #{reason}")
    {:error, reason}
  end
end
