defmodule Ex338Web.UserInvitationLive do
  @moduledoc false
  use Ex338Web, :live_view

  alias Ex338.Accounts

  def render(assigns) do
    ~H"""
    <.padded_container>
      <div class="mx-auto max-w-sm mt-20">
        <.header class="text-center">
          Invite User
          <:subtitle>Send a registration link by email.</:subtitle>
        </.header>

        <.simple_form for={@form} id="invitation_form" phx-submit="send_email">
          <.input
            field={@form[:email]}
            type="email"
            label="Email"
            placeholder="name@example.com"
            required
          />
          <:actions>
            <.button phx-disable-with="Sending..." class="w-full">
              Send Invite
            </.button>
          </:actions>
        </.simple_form>
        <p class="text-right mt-4">
          <.link
            href={~p"/"}
            class="text-sm font-medium text-indigo-600 hover:text-indigo-500 focus:outline-hidden focus:underline transition ease-in-out duration-150"
          >
            Back
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
    Accounts.deliver_registration_link(email, url(~p"/users/register"))

    info =
      "Invitation sent to #{email}"

    {:noreply, put_flash(socket, :info, info)}
  end
end
