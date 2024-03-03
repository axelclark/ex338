defmodule Ex338Web.PowInvitation.InvitationHTML do
  use Ex338Web, :html

  def edit(assigns) do
    ~H"""
    <div class="flex items-center justify-center min-h-screen px-4 py-2 sm:px-6 lg:px-8">
      <div class="w-full max-w-md">
        <div>
          <h2 class="text-3xl font-extrabold text-center text-gray-900 leading-9">
            Register for an account
          </h2>
        </div>
        <div class="mt-8">
          <.simple_form :let={f} for={@changeset} as={:user} action={@action} class="!bg-gray-200">
            <.error :if={@changeset.action}>
              Oops, something went wrong! Please check the errors below.
            </.error>
            <.input field={f[:email]} type="email" label="Email" />
            <.input field={f[:name]} type="text" label="Name" />
            <.input field={f[:password]} type="password" label="Password" />
            <.input field={f[:confirm_password]} type="password" label="Confirm New Password" />
            <:actions>
              <span class="block w-full rounded-md shadow-sm">
                <button
                  type="submit"
                  class="flex justify-center w-full px-4 py-2 text-sm font-medium text-white bg-indigo-600 border border-transparent rounded-md hover:bg-indigo-500 focus:outline-none focus:border-indigo-700 focus:shadow-outline-indigo active:bg-indigo-700 transition duration-150 ease-in-out"
                >
                  Register
                </button>
              </span>
            </:actions>
          </.simple_form>
        </div>
      </div>
    </div>
    """
  end

  def new(assigns) do
    ~H"""
    <.two_col_form :let={f} for={@changeset} action={~p"/invitations"}>
      <:title>
        Invite a new user
      </:title>
      <:description>
        Email a registration link to a new user.
      </:description>
      <.input field={f[:email]} label="Email" type="email" />

      <:actions>
        <.submit_buttons back_route={~p"/"} submit_text="Send" />
      </:actions>
    </.two_col_form>
    """
  end

  def show(assigns) do
    ~H"""
    <h1>Invitation</h1>

    <blockquote><%= @url %></blockquote>
    """
  end
end
