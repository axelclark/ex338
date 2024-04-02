defmodule Ex338.Chats do
  @moduledoc """
  The Chats context.
  """

  import Ecto.Query

  alias Ex338.Accounts.User
  alias Ex338.Chats.Chat
  alias Ex338.Chats.Message
  alias Ex338.Repo

  def subscribe(%Chat{} = chat, %User{}) do
    Phoenix.PubSub.subscribe(Ex338.PubSub, topic(chat))
  end

  def subscribe(_chat, nil), do: nil

  def create_chat(chat_params) do
    %Chat{}
    |> Chat.changeset(chat_params)
    |> Repo.insert()
  end

  def create_message(message_params) do
    %Message{}
    |> Message.changeset(message_params)
    |> Repo.insert()
    |> case do
      {:ok, message} ->
        message = Repo.preload(message, :user)
        broadcast(message, %Ex338.Events.MessageCreated{message: message})
        {:ok, message}

      other ->
        other
    end
  end

  def change_message(%Message{} = message, attrs \\ %{}) do
    Message.changeset(message, attrs)
  end

  def list_chats do
    Repo.all(Chat)
  end

  def get_chat(chat_id) do
    query =
      from c in Chat,
        where: c.id == ^chat_id,
        preload: [messages: :user]

    Repo.one(query)
  end

  defp broadcast(%Message{} = message, event) do
    Phoenix.PubSub.broadcast(Ex338.PubSub, topic(message), {__MODULE__, event})
  end

  defp topic(%Message{} = message), do: "chat:#{message.chat_id}"
  defp topic(%Chat{} = chat), do: "chat:#{chat.id}"
end
