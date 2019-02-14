defmodule Ex338Web.PowMailer do
  @moduledoc false
  use Pow.Phoenix.Mailer
  use Swoosh.Mailer, otp_app: :ex338

  import Swoosh.Email

  def cast(email) do
    new()
    |> from({"338 Commish", "no-reply@338admin.com"})
    |> to({"", email.user.email})
    |> subject(email.subject)
    |> text_body(email.text)
    |> html_body(email.html)
  end

  def process(email), do: deliver(email)
end
