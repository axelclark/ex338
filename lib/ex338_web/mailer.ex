defmodule Ex338Web.Mailer do
  @moduledoc false
  use Swoosh.Mailer, otp_app: :ex338

  require Logger

  def handle_delivery({:ok, _result}) do
    Logger.info "Sent email notification"
  end

  def handle_delivery({:error, {_, reason}}) do
    Logger.error "Email failed to send: #{reason}"
  end
end
