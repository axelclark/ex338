defmodule Ex338.TradeVote.Store do
  @moduledoc false

  alias Ex338.{TradeVote, Repo}

  def create_vote(attrs) do
    %TradeVote{}
    |> TradeVote.changeset(attrs)
    |> Repo.insert
  end
end
