defmodule Ex338.User do
  @moduledoc false
  use Ecto.Schema
  use Ex338Web, :model

  alias Ex338.User

  schema "users" do
    field(:name, :string)
    field(:email, :string)
    field(:slack_name, :string)
    field(:admin, :boolean)
    has_many(:owners, Ex338.Owner)
    has_many(:submitted_trades, Ex338.Trade, foreign_key: :submitted_by_user_id)
    has_many(:trade_votes, Ex338.TradeVote)
    has_many(:fantasy_teams, through: [:owners, :fantasy_team])

    timestamps()
  end

  def admin_emails do
    from(
      u in User,
      where: u.admin == true,
      select: {u.name, u.email}
    )
  end

  def alphabetical(query), do: from(u in query, order_by: u.name)

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:name, :email, :slack_name, :admin])
    |> validate_required([:name, :email])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
  end

  def preload_assocs(query) do
    from(
      u in query,
      preload: [owners: :fantasy_team]
    )
  end

  def user_changeset(user, params \\ %{}) do
    user
    |> cast(params, [:name, :email, :slack_name])
    |> validate_required([:name, :email])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
  end
end
