defmodule Ex338Web.UserSettingsLive do
  @moduledoc false
  use Ex338Web, :live_view

  alias Ex338.Accounts

  def render(assigns) do
    ~H"""
    <.padded_container>
      <.header class="text-center mt-10">
        Account Settings
        <:subtitle>Manage your account email address and password settings</:subtitle>
      </.header>

      <div class="space-y-12 divide-y max-w-lg m-auto">
        <div>
          <.simple_form
            for={@email_form}
            id="email_form"
            phx-submit="update_email"
            phx-change="validate_email"
            class="bg-gray-200!"
          >
            <.input field={@email_form[:email]} type="email" label="Email" required />
            <.input
              field={@email_form[:current_password]}
              name="current_password"
              id="current_password_for_email"
              type="password"
              label="Current password"
              value={@email_form_current_password}
              required
            />
            <:actions>
              <.button phx-disable-with="Changing...">Change Email</.button>
            </:actions>
          </.simple_form>
        </div>
        <div>
          <.simple_form
            for={@password_form}
            id="password_form"
            action={~p"/users/log_in?_action=password_updated"}
            method="post"
            phx-change="validate_password"
            phx-submit="update_password"
            phx-trigger-action={@trigger_submit}
            class="bg-gray-200!"
          >
            <.input
              field={@password_form[:email]}
              type="hidden"
              id="hidden_user_email"
              value={@current_email}
            />
            <.input
              field={@password_form[:password]}
              type="password"
              label="New password"
              required
              phx-debounce="blur"
            />
            <.input
              field={@password_form[:password_confirmation]}
              type="password"
              label="Confirm new password"
            />
            <.input
              field={@password_form[:current_password]}
              name="current_password"
              type="password"
              label="Current password"
              id="current_password_for_password"
              value={@current_password}
              required
            />
            <:actions>
              <.button phx-disable-with="Changing...">Change Password</.button>
            </:actions>
          </.simple_form>
        </div>
        <div>
          <.header class="text-base!">
            API Tokens
            <:subtitle>
              Personal access tokens let the HTTP API and MCP server act as you. A token
              carries your permissions—owners can act on their own teams, admins on anything.
            </:subtitle>
          </.header>

          <div
            :if={@new_api_token}
            id="new_api_token"
            class="mt-4 rounded-md border border-yellow-300 bg-yellow-50 p-4"
          >
            <p class="text-sm font-semibold text-yellow-800">
              Copy your token now—it won't be shown again.
            </p>
            <code class="mt-2 block break-all rounded bg-white p-2 text-sm">{@new_api_token}</code>
          </div>

          <.simple_form
            for={@token_form}
            id="api_token_form"
            phx-submit="create_api_token"
            class="bg-gray-200!"
          >
            <.input
              field={@token_form[:name]}
              type="text"
              label="Token name"
              placeholder="e.g. Claude MCP"
              required
            />
            <:actions>
              <.button phx-disable-with="Generating...">Generate Token</.button>
            </:actions>
          </.simple_form>

          <ul :if={@api_tokens != []} role="list" class="mt-6 divide-y divide-gray-300">
            <li
              :for={token <- @api_tokens}
              id={"api_token_#{token.id}"}
              class="flex items-center justify-between py-3"
            >
              <div>
                <p class="text-sm font-medium">{token.sent_to || "Unnamed token"}</p>
                <p class="text-xs text-gray-500">
                  Created {Calendar.strftime(token.inserted_at, "%b %-d, %Y")}
                </p>
              </div>
              <.button
                phx-click="revoke_api_token"
                phx-value-id={token.id}
                data-confirm="Revoke this token? Any client using it will stop working."
                class="bg-red-600! hover:bg-red-500!"
              >
                Revoke
              </.button>
            </li>
          </ul>
        </div>
      </div>
    </.padded_container>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_user, token) do
        :ok ->
          put_flash(socket, :info, "Email changed successfully.")

        :error ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    email_changeset = Accounts.change_user_email(user)
    password_changeset = Accounts.change_user_password(user)

    socket =
      socket
      |> assign(:current_password, nil)
      |> assign(:email_form_current_password, nil)
      |> assign(:current_email, user.email)
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:trigger_submit, false)
      |> assign(:new_api_token, nil)
      |> assign(:api_tokens, Accounts.list_user_api_tokens(user))
      |> assign(:token_form, to_form(%{"name" => ""}, as: :token))

    {:ok, socket}
  end

  def handle_event("validate_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    email_form =
      socket.assigns.current_user
      |> Accounts.change_user_email(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form, email_form_current_password: password)}
  end

  def handle_event("update_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_user_update_email_instructions(
          applied_user,
          user.email,
          &url(~p"/users/settings/confirm_email/#{&1}")
        )

        info = "A link to confirm your email change has been sent to the new address."
        {:noreply, socket |> put_flash(:info, info) |> assign(email_form_current_password: nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    password_form =
      socket.assigns.current_user
      |> Accounts.change_user_password(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form, current_password: password)}
  end

  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        password_form =
          user
          |> Accounts.change_user_password(user_params)
          |> to_form()

        {:noreply, assign(socket, trigger_submit: true, password_form: password_form)}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end
  end

  def handle_event("create_api_token", %{"token" => %{"name" => name}}, socket) do
    user = socket.assigns.current_user
    token = Accounts.create_user_api_token(user, String.trim(name))

    socket =
      socket
      |> assign(:new_api_token, token)
      |> assign(:api_tokens, Accounts.list_user_api_tokens(user))
      |> assign(:token_form, to_form(%{"name" => ""}, as: :token))
      |> put_flash(:info, "API token generated.")

    {:noreply, socket}
  end

  def handle_event("revoke_api_token", %{"id" => id}, socket) do
    user = socket.assigns.current_user

    socket =
      case Accounts.delete_user_api_token(user, id) do
        :ok ->
          socket
          |> assign(:api_tokens, Accounts.list_user_api_tokens(user))
          |> assign(:new_api_token, nil)
          |> put_flash(:info, "API token revoked.")

        {:error, :not_found} ->
          put_flash(socket, :error, "Token not found.")
      end

    {:noreply, socket}
  end
end
