defmodule Ex338.FantasyLeagues.FantasyLeagueDraft do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  schema "fantasy_league_drafts" do
    belongs_to(:fantasy_league, Ex338.FantasyLeagues.FantasyLeague)
    belongs_to(:championship, Ex338.Championships.Championship)
    belongs_to(:chat, Ex338.Chats.Chat)

    timestamps()
  end

  @doc false
  def changeset(fantasy_league_draft, attrs) do
    fantasy_league_draft
    |> cast(attrs, [:chat_id, :championship_id, :fantasy_league_id])
    |> validate_required([:fantasy_league_id, :chat_id])
    |> unique_constraint([:championship_id, :fantasy_league_id])
    |> unique_constraint([:chat_id])
  end
end
