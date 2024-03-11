defmodule Ex338Web.UserNotifier do
  @moduledoc false
  import Swoosh.Email

  alias Ex338Web.Mailer

  require Logger

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from(Ex338Web.Mailer.default_from_name_and_email())
      |> subject(subject)
      |> text_body(body)

    case Mailer.deliver(email) do
      {:ok, _} ->
        Logger.info("Sent user email notification")
        {:ok, email}

      {:error, {_, reason}} ->
        Logger.warning("Sending email failed: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(user, url) do
    deliver(user.email, "Confirmation instructions", """

    ==============================

    Hi #{user.email},

    You can confirm your account by visiting the URL below:

    #{url}

    If you didn't create an account with us, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, url) do
    deliver(user.email, "Reset password instructions", """

    ==============================

    Hi #{user.email},

    You can reset your password by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    deliver(user.email, "Update email instructions", """

    ==============================

    Hi #{user.email},

    You can change your email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to register as a new user.
  """
  def deliver_registration_link(email, url) do
    deliver(email, "Register for The 338 Challenge", """

    ==============================

    Hi #{email},

    Please register for The 338 Challenge by visiting the URL below:

    #{url}

    - The Commish

    ==============================
    """)
  end
end
