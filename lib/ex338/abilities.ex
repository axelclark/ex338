defimpl Canada.Can, for: Ex338.User do
  alias Ex338.{User, DraftPick, FantasyTeam, Waiver, InSeasonDraftPick}

  def can?(%User{admin: true}, _, _), do: true

  def can?(%User{id: user_id}, action, %User{id: user_id})
      when action in [:edit, :update] do
    true
  end

  def can?(%User{}, action, %User{})
      when action in [:edit, :update] do
    false
  end

  def can?(%User{}, action, nil)
      when action in [:edit, :update] do
    false
  end

  def can?(%User{id: user_id}, action, model)
      when action in [:edit, :update, :create, :new] do
    owner?(user_id, model)
  end

  def can?(%User{id: _}, _, _), do: false

  defp owner?(user_id, %DraftPick{} = draft_pick) do
    owners = draft_pick.fantasy_team.owners
    Enum.any?(owners, &(&1.user_id == user_id))
  end

  defp owner?(user_id, %FantasyTeam{owners: owners}) do
    Enum.any?(owners, &(&1.user_id == user_id))
  end

  defp owner?(user_id, %Waiver{} = waiver) do
    owners = waiver.fantasy_team.owners
    Enum.any?(owners, &(&1.user_id == user_id))
  end

  defp owner?(user_id, %InSeasonDraftPick{} = draft_pick) do
    owners = draft_pick.draft_pick_asset.fantasy_team.owners
    Enum.any?(owners, &(&1.user_id == user_id))
  end
end
