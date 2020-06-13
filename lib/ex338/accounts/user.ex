defmodule Ex338.Accounts.User do
  @moduledoc false
  use Ecto.Schema
  use Ex338Web, :model

  use Pow.Ecto.Schema,
    password_min_length: 6,
    password_hash_methods: {&Bcrypt.hash_pwd_salt/1, &Bcrypt.verify_pass/2}

  use Pow.Extension.Ecto.Schema,
    extensions: [PowResetPassword, PowPersistentSession, PowInvitation]

  alias Ex338.Accounts.User

  schema "users" do
    field(:name, :string)
    field(:email, :string)
    field(:slack_name, :string)
    field(:admin, :boolean)
    has_many(:owners, Ex338.FantasyTeams.Owner)
    has_many(:submitted_trades, Ex338.Trades.Trade, foreign_key: :submitted_by_user_id)
    has_many(:trade_votes, Ex338.Trades.TradeVote)
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
    |> pow_user_id_field_changeset(params)
    |> pow_password_changeset(params)
    |> pow_extension_changeset(params)
    |> validate_required([:name, :email])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
  end

  def preload_assocs(query) do
    from(
      u in query,
      preload: [owners: [fantasy_team: :fantasy_league]]
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
