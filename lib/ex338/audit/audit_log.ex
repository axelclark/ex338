defmodule Ex338.Audit.AuditLog do
  @moduledoc """
  An append-only record of a write action taken through the app.

  Captures who acted (`user`, optionally the `api_token` used), how the request
  arrived (`source`: web/api/mcp), what they did (`action`), the affected
  resource (`resource_type`/`resource_id`), and the `outcome`
  (success/denied/error). `metadata` holds lightweight details such as the
  submitted params or an error reason.
  """
  use Ecto.Schema

  import Ecto.Changeset

  @sources ~w(web api mcp)
  @outcomes ~w(success denied error)

  schema "audit_logs" do
    field :source, :string
    field :action, :string
    field :resource_type, :string
    field :resource_id, :integer
    field :outcome, :string
    field :metadata, :map, default: %{}
    belongs_to :user, Ex338.Accounts.User
    belongs_to :api_token, Ex338.Accounts.UserToken
    belongs_to :fantasy_league, Ex338.FantasyLeagues.FantasyLeague

    timestamps(updated_at: false, type: :utc_datetime)
  end

  def changeset(audit_log, attrs) do
    audit_log
    |> cast(attrs, [
      :user_id,
      :api_token_id,
      :fantasy_league_id,
      :source,
      :action,
      :resource_type,
      :resource_id,
      :outcome,
      :metadata
    ])
    |> validate_required([:source, :action, :outcome])
    |> validate_inclusion(:source, @sources)
    |> validate_inclusion(:outcome, @outcomes)
  end
end
