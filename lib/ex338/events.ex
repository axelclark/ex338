defmodule Ex338.Events do
  @moduledoc """
  Defines Event structs for use within the pubsub system.
  """
  defmodule MessageCreated do
    @moduledoc false
    defstruct message: nil
  end
end
