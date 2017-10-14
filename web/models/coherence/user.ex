defmodule Ex338.User do
  @moduledoc false
  use Ecto.Schema
  use Ex338.Web, :model
  use Coherence.Schema

  alias Ex338.User

  schema "users" do
    field :name, :string
    field :email, :string
    field :admin, :boolean
    has_many :owners, Ex338.Owner
    has_many :fantasy_teams, through: [:owners, :fantasy_team]
    coherence_schema()

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [:name, :email, :admin] ++ coherence_fields())
    |> validate_required([:name, :email])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> validate_coherence(params)
  end

  def changeset(model, params, :password) do
    model
    |> cast(params, ~w(password password_confirmation reset_password_token reset_password_sent_at))
    |> validate_coherence_password_reset(params)
  end

  def admin_emails do
    from u in User,
      where: u.admin == true,
      select: {u.name, u.email}
  end

  def my_fantasy_league(%User{id: id}) do
    from u in User,
      join: o in assoc(u, :owners),
      join: f in assoc(o, :fantasy_team),
      join: l in assoc(f, :fantasy_league),
      where: u.id == ^id,
      order_by: [desc: l.year],
      limit: 1,
      select: l
  end
end
