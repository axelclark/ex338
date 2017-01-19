defmodule Ex338.Championship do
  @moduledoc false
  use Ex338.Web, :model

  alias Ex338.{SportsLeague, Repo, ChampionshipResult, ChampionshipSlot}

  @categories ["overall", "event"]

  schema "championships" do
    field :title, :string
    field :category, :string
    field :waiver_deadline_at, Ecto.DateTime
    field :trade_deadline_at, Ecto.DateTime
    field :championship_at, Ecto.DateTime
    belongs_to :sports_league, SportsLeague
    has_many :championship_results, ChampionshipResult
    has_many :championship_slots, ChampionshipSlot
    has_many :fantasy_players, through: [:championship_results, :fantasy_player]

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(championship_struct, params \\ %{}) do
    championship_struct
    |> cast(params, [:title, :category, :waiver_deadline_at, :trade_deadline_at,
                     :championship_at, :sports_league_id])
    |> validate_required([:title, :category, :waiver_deadline_at,
                          :trade_deadline_at, :championship_at,
                          :sports_league_id])
  end

  def categories, do: @categories

  def get_all(query) do
    query
    |> preload_assocs
    |> earliest_first
    |> Repo.all
  end

  def get_championship_by_league(query, id, league_id) do
    query
    |> preload_assocs_by_league(league_id)
    |> Repo.get!(id)
  end

  def get_championship(query, id) do
    query
    |> preload_assocs
    |> Repo.get!(id)
  end

  def earliest_first(query) do
    from c in query,
      order_by: [asc: :championship_at, asc: :category]
  end

  def future_championships(query) do
    from c in query,
      where: c.championship_at > ago(0, "second"),
      order_by: c.championship_at
  end

  def all_with_overall_waivers_open(query) do
    from c in query,
      where: c.waiver_deadline_at > ago(0, "second"),
      where: c.category == "overall"
  end

  def preload_assocs(query) do
    results =
      ChampionshipResult.preload_assocs_and_order_results(ChampionshipResult)

    from c in query,
     preload: [:sports_league, championship_results: ^results]
  end

  def preload_assocs_by_league(query, league_id) do
    results =
      ChampionshipResult
      |> ChampionshipResult.preload_ordered_assocs_by_league(league_id)

    slots =
      ChampionshipSlot
      |> ChampionshipSlot.preload_assocs_by_league(league_id)


    from c in query,
     preload: [:sports_league,championship_slots: ^slots,
               championship_results: ^results,]
  end
end
