defmodule Ex338.Trade.Store do
  @moduledoc false

  use Ex338.Web, :model

  alias Ex338.{Trade, Repo}

  def all_for_league(league_id) do
    Trade
    |> Trade.by_league(league_id)
    |> Trade.preload_assocs
    |> Trade.newest_first
    |> Repo.all
  end
end
