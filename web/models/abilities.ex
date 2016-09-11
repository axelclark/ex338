defimpl Canada.Can, for: Ex338.User do
  alias Ex338.{User}

  def can?(%User{admin: true}, _, _), do: true

  def can?(%User{id: user_id}, action, draft_pick)
    when action in [:edit, :update] do
      owner?(user_id, draft_pick)
  end

  def can?(%User{id: _}, _, _), do: false

  defp owner?(user_id, draft_pick) do
    draft_pick.fantasy_team.owners
    |> Enum.any?(&(&1.user_id == user_id))
  end
end
