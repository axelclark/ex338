defmodule Ex338.Chats.Chat do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Ex338.Chats.Message

  schema "chats" do
    field :room_name, :string

    has_many :messages, Message, preload_order: [asc: :inserted_at]
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:room_name])
    |> validate_required([:room_name])
    |> unique_constraint(:room_name)
  end
end
