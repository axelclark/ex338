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
        {:noreply,
         socket
         |> push_event("clear-textarea", %{id: "message_content"})
         |> push_patch(to: socket.assigns.patch)}

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
    <div class="flex gap-x-3 pt-3 px-4 sm:px-6">
      <.user_icon name={@current_user.name} class="!mt-0" />
      <.form
        id="create-message-form"
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
            type="commenttextarea"
            rows="2"
            class="block w-full resize-none border-0 bg-transparent py-1.5 text-gray-900 placeholder:text-gray-400 focus:ring-0 sm:text-sm sm:leading-6"
            placeholder="Add your comment..."
            phx-hook="EnterSubmitHook"
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
      {get_initials(@name)}
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
