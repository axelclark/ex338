defmodule Ex338.Rulebooks.Rulebook do
  @moduledoc false
  @enforce_keys [:year, :draft_method, :body]
  defstruct [:year, :draft_method, :body]

  def build(_filename, attrs, body) do
    struct!(__MODULE__, [body: body] ++ Map.to_list(attrs))
  end
end
