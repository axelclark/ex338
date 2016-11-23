defmodule Ex338.ChampionshipResult do
  @moduledoc false

  use Ex338.Web, :model

  schema "championship_results" do
    belongs_to :championship, Ex338.Championship
    belongs_to :fantasy_player, Ex338.FantasyPlayer
    field :rank, :integer
    field :points, :integer

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(result_struct, params \\ %{}) do
    result_struct
    |> cast(params, [:championship_id, :fantasy_player_id, :rank, :points])
    |> validate_required([:championship_id, :fantasy_player_id, :rank, :points])
  end

  def order_by_rank(query) do
    from c in query, order_by: c.rank
  end

  def preload_assocs(query) do
    from c in query,
     preload: [:fantasy_player]
  end

  def get_assocs_and_order_results(query) do
    query
    |> preload_assocs
    |> order_by_rank
  end

  def only_overall(query) do
    from cr in query,
      inner_join: c in assoc(cr, :championship),
      on: cr.championship_id == c.id and c.category == "overall"
  end
end
