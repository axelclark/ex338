defmodule Ex338.ChatsTest do
  use Ex338.DataCase

  alias Ex338.Chats
  alias Ex338.Chats.Message

  describe "messages" do
    @invalid_attrs %{content: nil}

    test "create_message/1 with valid data creates a message" do
      chat = insert(:chat)
      user = insert(:user)
      valid_attrs = %{content: "some content", user_id: user.id, chat_id: chat.id}

      assert {:ok, %Message{} = message} = Chats.create_message(valid_attrs)
      assert message.content == "some content"
    end

    test "create_message/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chats.create_message(@invalid_attrs)
    end
  end
end
