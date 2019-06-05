defmodule Ex338.User do
  @moduledoc false
  use Ecto.Schema
  use Ex338Web, :model

  use Pow.Ecto.Schema,
    password_min_length: 6,
    password_hash_methods: {&Comeonin.Bcrypt.hashpwsalt/1, &Comeonin.Bcrypt.checkpw/2}

  use Pow.Extension.Ecto.Schema,
    extensions: [PowResetPassword, PowPersistentSession, PowInvitation]

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
    pow_user_fields()

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
    |> pow_changeset(params)
    |> pow_extension_changeset(params)
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
