defmodule Ex338Web.Presence do
  @moduledoc false
  use Phoenix.Presence,
    otp_app: :ex338,
    pubsub_server: Ex338.PubSub

  alias Ex338Web.Presence

  def list_presences(topic) do
    topic
    |> Presence.list()
    |> Enum.map(fn {_user_id, data} ->
      List.first(data[:metas])
    end)
  end
end
