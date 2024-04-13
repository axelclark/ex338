defmodule Ex338.Chats.Message do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  schema "messages" do
    field :content, :string
    belongs_to :user, Ex338.Accounts.User
    belongs_to :chat, Ex338.Chats.Chat

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(message, attrs \\ %{}) do
    message
    |> cast(attrs, [:content, :user_id, :chat_id])
    |> validate_required([:content, :chat_id])
    |> validate_length(:content, min: 1, max: 280)
  end
end
