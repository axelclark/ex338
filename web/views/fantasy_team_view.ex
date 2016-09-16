defmodule Ex338.FantasyTeamView do
  use Ex338.Web, :view
  alias Ex338.{FantasyTeam, User}
  import Ex338.RosterAdmin, only: [primary_positions: 1,
                                   flex_and_unassigned_positions: 1]

  def sort_by_position(query) do
    Enum.sort(query, &(&1.position <= &2.position))
  end

  def owner?(%User{id: id}, %FantasyTeam{owners: owners}) do
    owners
    |> Enum.any?(&(&1.user_id == id))
  end
end
