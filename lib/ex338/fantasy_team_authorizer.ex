defmodule Ex338.FantasyTeamAuthorizer do
  @moduledoc """
  A module to authorize access to actions for a Fantasy Team
  """

  alias Ex338.Accounts.User
  alias Ex338.FantasyTeams.FantasyTeam
  alias Ex338.InSeasonDraftPicks.InSeasonDraftPick
  alias Ex338.Repo

  def authorize(_action, %User{} = %{admin: true}, _schema) do
    :ok
  end

  def authorize(:edit_team, %User{} = user, %FantasyTeam{} = fantasy_team) do
    if owner?(user.id, fantasy_team) do
      :ok
    else
      {:error, :not_authorized}
    end
  end

  def authorize(
        :edit_in_season_draft_pick,
        %User{} = user,
        %InSeasonDraftPick{} = in_season_draft_pick
      ) do
    if owner?(user.id, in_season_draft_pick) do
      :ok
    else
      {:error, :not_authorized}
    end
  end

  defp owner?(user_id, %FantasyTeam{} = fantasy_team) do
    fantasy_team = Repo.preload(fantasy_team, :owners)
    owners = fantasy_team.owners
    Enum.any?(owners, &(&1.user_id == user_id))
  end

  defp owner?(user_id, %InSeasonDraftPick{} = draft_pick) do
    draft_pick = Repo.preload(draft_pick, draft_pick_asset: [fantasy_team: :owners])
    owners = draft_pick.draft_pick_asset.fantasy_team.owners
    Enum.any?(owners, &(&1.user_id == user_id))
  end
end
