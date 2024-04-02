defmodule Ex338Web.ChampionshipLive.ChatComponent do
  @moduledoc false
  use Ex338Web, :live_component

  alias Ex338.Chats

  @impl true
  def update(%{message: message} = assigns, socket) do
    changeset = Chats.change_message(message)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:message, message)
     |> assign_form(changeset)}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  @impl true
  def handle_event("validate", %{"message" => message_params}, socket) do
    message_params = add_chat_and_user_to_params(message_params, socket)

    changeset =
      socket.assigns.message
      |> Chats.change_message(message_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"message" => message_params}, socket) do
    message_params = add_chat_and_user_to_params(message_params, socket)

    case Chats.create_message(message_params) do
      {:ok, _message} ->
        {:noreply, push_patch(socket, to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp add_chat_and_user_to_params(params, socket) do
    params
    |> Map.put("user_id", socket.assigns.current_user.id)
    |> Map.put("chat_id", socket.assigns.chat.id)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="overflow-hidden bg-white shadow sm:rounded-lg">
      <div class="px-4 py-5 border-b border-gray-200 sm:px-6">
        <ul
          id="messages"
          phx-update="stream"
          role="list"
          phx-hook="ChatScrollToBottom"
          class="space-y-4 flex flex-col h-[800px] overflow-y-auto overflow-x-hidden pb-6"
        >
          <.comment :for={{id, message} <- @messages} id={id} message={message} />
        </ul>

        <div class="flex gap-x-3">
          <.user_icon name={@current_user.name} class="!mt-0" />
          <.form
            id="create-message"
            for={@form}
            phx-target={@myself}
            phx-change="validate"
            phx-submit="save"
            class="relative flex-auto"
          >
            <div class="overflow-hidden rounded-lg pb-12 shadow-sm ring-1 ring-inset ring-gray-300 focus-within:ring-2 focus-within:ring-indigo-600">
              <label for="comment" class="sr-only">Add your comment</label>
              <.input
                field={@form[:content]}
                phx-debounce="blur"
                type="commenttextarea"
                rows="2"
                class="block w-full resize-none border-0 bg-transparent py-1.5 text-gray-900 placeholder:text-gray-400 focus:ring-0 sm:text-sm sm:leading-6"
                placeholder="Add your comment..."
              />
            </div>

            <div class="absolute inset-x-0 bottom-0 flex justify-end py-2 pl-3 pr-2">
              <button
                type="submit"
                class="rounded-md bg-white px-2.5 py-1.5 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
              >
                Comment
              </button>
            </div>
          </.form>
        </div>
      </div>
    </div>
    """
  end

  defp comment(%{message: %{user: nil}} = assigns) do
    ~H"""
    <li id={@id} class="flex gap-x-4">
      <div class="flex h-6 w-6 flex-none items-center justify-center bg-white">
        <.icon name="hero-check-circle" class="h-6 w-6 text-indigo-600" />
      </div>
      <p class="flex-auto py-0.5 text-xs leading-5 text-gray-500">
        <%= @message.content %>
      </p>
    </li>
    """
  end

  defp comment(assigns) do
    ~H"""
    <li id={@id} class="flex gap-x-4">
      <.user_icon name={@message.user.name} />
      <div class="flex-auto">
        <div class="flex justify-between items-start gap-x-4">
          <div class="text-xs leading-5 font-medium text-gray-900">
            <%= @message.user.name %>
          </div>
        </div>
        <p class="text-sm leading-6 text-gray-500">
          <%= @message.content %>
        </p>
      </div>
    </li>
    """
  end

  attr :name, :string, required: true
  attr :class, :string, default: nil

  defp user_icon(assigns) do
    ~H"""
    <div class={[
      "h-6 w-6 flex flex-shrink-0 items-center justify-center bg-gray-600 rounded-full text-xs font-medium text-white",
      @class
    ]}>
      <%= get_initials(@name) %>
    </div>
    """
  end

  defp get_initials(name) do
    name
    |> String.split(" ")
    |> Enum.take(2)
    |> Enum.map_join("", &String.at(&1, 0))
  end
end
