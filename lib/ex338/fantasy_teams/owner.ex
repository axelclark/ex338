defmodule Ex338.FantasyTeams.Owner do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query, warn: false

  schema "owners" do
    belongs_to(:fantasy_team, Ex338.FantasyTeams.FantasyTeam)
    belongs_to(:user, Ex338.Accounts.User)
    field(:rules, OwnerRulesEnum, default: "unaccepted")

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(owner, params \\ %{}) do
    owner
    |> cast(params, [:fantasy_team_id, :user_id, :rules])
    |> validate_required([:fantasy_team_id, :user_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:fantasy_team_id)
  end

  def by_league(query, league_id) do
    from(
      o in query,
      join: f in assoc(o, :fantasy_team),
      where: f.fantasy_league_id == ^league_id,
      order_by: [asc: f.team_name]
    )
  end

  def by_team(query, team_id) do
    from(
      o in query,
      where: o.fantasy_team_id == ^team_id
    )
  end

  def email_recipients_for_league(query, league_id) do
    query
    |> by_league(league_id)
    |> join(:inner, [o], u in assoc(o, :user))
    |> select([o, f, u], {u.name, u.email})
  end

  def email_recipients_for_team(query, team_id) do
    query
    |> by_team(team_id)
    |> join(:inner, [o], u in assoc(o, :user))
    |> select([o, u], {u.name, u.email})
  end
end
