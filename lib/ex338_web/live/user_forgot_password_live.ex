defmodule Ex338Web.UserForgotPasswordLive do
  @moduledoc false
  use Ex338Web, :live_view

  alias Ex338.Accounts

  def render(assigns) do
    ~H"""
    <.padded_container>
      <div class="mx-auto max-w-sm mt-20">
        <.header class="text-center">
          Forgot your password?
          <:subtitle>We'll send a password reset link to your inbox</:subtitle>
        </.header>

        <.simple_form
          for={@form}
          id="reset_password_form"
          phx-submit="send_email"
          class="bg-gray-200!"
        >
          <.input field={@form[:email]} type="email" placeholder="Email" required />
          <:actions>
            <.button phx-disable-with="Sending..." class="w-full">
              Send password reset instructions
            </.button>
          </:actions>
        </.simple_form>
        <p class="text-right mt-4">
          <.link
            href={~p"/users/log_in"}
            class="text-sm font-medium text-indigo-600 hover:text-indigo-500 focus:outline-hidden focus:underline transition ease-in-out duration-150"
          >
            Log in
          </.link>
        </p>
      </div>
    </.padded_container>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "user"))}
  end

  def handle_event("send_email", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_reset_password_instructions(
        user,
        &url(~p"/users/reset_password/#{&1}")
      )
    end

    info =
      "If your email is in our system, you will receive instructions to reset your password shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end
