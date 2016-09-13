defmodule Ex338.User do
  use Ex338.Web, :model
  use Coherence.Schema

  alias Ex338.{Owner, User}

  schema "users" do
    field :name, :string
    field :email, :string
    field :admin, :boolean
    has_many :owners, Owner
    has_many :fantasy_teams, through: [:owners, :fantasy_team]
    coherence_schema

    timestamps
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [:name, :email, :admin] ++ coherence_fields)
    |> validate_required([:name, :email])
    |> unique_constraint(:email)
    |> validate_coherence(params)
  end

  def admin_emails do
    from u in User,
      where: u.admin == true,
      select: {u.name, u.email}
  end
end
