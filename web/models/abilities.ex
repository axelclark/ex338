defimpl Canada.Can, for: Ex338.User do
  alias Ex338.{User, DraftPick, FantasyTeam, Waiver}

  def can?(%User{admin: true}, _, _), do: true

  def can?(%User{id: user_id}, action, model)
    when action in [:edit, :update, :create, :new] do
      owner?(user_id, model)
  end

  def can?(%User{id: _}, _, _), do: false

  defp owner?(user_id, %DraftPick{} = draft_pick) do
    draft_pick.fantasy_team.owners
    |> Enum.any?(&(&1.user_id == user_id))
  end

  defp owner?(user_id, %FantasyTeam{owners: owners}) do
    owners
    |> Enum.any?(&(&1.user_id == user_id))
  end

  defp owner?(user_id, %Waiver{} = waiver) do
    waiver.fantasy_team.owners
    |> Enum.any?(&(&1.user_id == user_id))
  end
end
