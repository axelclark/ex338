defmodule Ex338.InSeasonDraftPick.Admin do
  @moduledoc false

  alias Ex338.{Commish, InSeasonDraftPick, RosterPosition}
  alias Ecto.Multi

  def update(draft_pick, params) do

    Multi.new
    |> update_pick(draft_pick, params)
    |> update_position(draft_pick)
    |> new_position(draft_pick, params)
    |> send_email(draft_pick)
  end

  defp update_pick(multi, draft_pick, params) do
    Multi.update(multi, :update_pick,
      InSeasonDraftPick.owner_changeset(draft_pick, params))
  end

  defp update_position(multi, draft_pick) do
    params = %{
      "released_at" => Ecto.DateTime.utc(),
      "status" => "drafted_pick"
    }

    Multi.update(multi, :update_position,
      RosterPosition.changeset(draft_pick.draft_pick_asset, params))
  end

  defp new_position(multi, draft_pick, %{"drafted_player_id" => player_id}) do
    params = %{
      "fantasy_team_id" => draft_pick.draft_pick_asset.fantasy_team_id,
      "fantasy_player_id" => player_id,
      "position" => draft_pick.draft_pick_asset.position,
      "active_at" => Ecto.DateTime.utc(),
      "status" => "active"
    }

    Multi.insert(multi, :new_position,
      RosterPosition.changeset(%RosterPosition{}, params))
  end

  defp send_email(multi, draft_pick) do
    league_id = draft_pick.draft_pick_asset.fantasy_team.fantasy_league_id

    Multi.run(multi, :email,
      &(Commish.InSeasonDraftEmail.send_update(&1, league_id)))
  end
end
