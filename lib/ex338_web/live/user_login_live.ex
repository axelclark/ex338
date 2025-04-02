defmodule Ex338Web.UserLoginLive do
  @moduledoc false
  use Ex338Web, :live_view

  def render(assigns) do
    ~H"""
    <.padded_container>
      <div class="mx-auto max-w-sm mt-20">
        <.header class="text-center">
          Sign in to The 338 Challenge
          <:subtitle></:subtitle>
        </.header>

        <.simple_form
          for={@form}
          id="login_form"
          action={~p"/users/log_in"}
          phx-update="ignore"
          class="bg-gray-200! max-w-md m-auto"
        >
          <.input field={@form[:email]} type="email" label="Email" required />
          <.input field={@form[:password]} type="password" label="Password" required />

          <:actions>
            <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />
            <.link
              href={~p"/users/reset_password"}
              class="text-sm font-medium text-indigo-600 hover:text-indigo-500 focus:outline-hidden focus:underline transition ease-in-out duration-150"
            >
              Forgot your password?
            </.link>
          </:actions>
          <:actions>
            <.button phx-disable-with="Signing in..." class="w-full">
              Sign in <span aria-hidden="true">→</span>
            </.button>
          </:actions>
        </.simple_form>
      </div>
    </.padded_container>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
