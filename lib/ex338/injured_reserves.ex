defmodule Ex338.InjuredReserves do
  @moduledoc """
  An interface to InjuredReseve
  """

  import Ecto, only: [build_assoc: 2]

  alias Ex338.InjuredReserves.Admin
  alias Ex338.InjuredReserves.InjuredReserve
  alias Ex338.Repo
  alias Ex338.RosterPositions

  def change_injured_reserve(%InjuredReserve{} = injured_reserve, attrs \\ %{}) do
    InjuredReserve.changeset(injured_reserve, attrs)
  end

  def create_injured_reserve(fantasy_team, attrs) do
    fantasy_team
    |> build_assoc(:injured_reserves)
    |> InjuredReserve.changeset(attrs)
    |> Repo.insert()
  end

  def get_ir!(id) do
    InjuredReserve
    |> InjuredReserve.preload_assocs()
    |> Repo.get!(id)
  end

  def list_irs_for_league(league_id) do
    InjuredReserve
    |> InjuredReserve.by_league(league_id)
    |> InjuredReserve.preload_assocs()
    |> Repo.all()
  end

  def list_injured_reserves(criteria \\ []) when is_list(criteria) do
    query = InjuredReserve.preload_assocs(InjuredReserve)

    criteria
    |> Enum.reduce(query, fn
      {:fantasy_league_id, fantasy_league_id}, query ->
        InjuredReserve.by_league(query, fantasy_league_id)

      {:fantasy_league, %{id: fantasy_league_id}}, query ->
        InjuredReserve.by_league(query, fantasy_league_id)

      {:statuses, statuses}, query ->
        InjuredReserve.by_status(query, statuses)
    end)
    |> Repo.all()
  end

  def update_injured_reserve(injured_reserve, %{"status" => "approved"}) do
    %{injured_player_id: player_id, fantasy_team_id: team_id} = injured_reserve
    position = get_roster_position(player_id, team_id, "active")

    injured_reserve
    |> Admin.approve_injured_reserve(position)
    |> Repo.transaction()
  end

  def update_injured_reserve(injured_reserve, %{"status" => "rejected"}) do
    injured_reserve
    |> Admin.reject_injured_reserve()
    |> Repo.transaction()
  end

  def update_injured_reserve(injured_reserve, %{"status" => "returned"}) do
    %{
      injured_player_id: injured_player_id,
      replacement_player_id: replacement_player_id,
      fantasy_team_id: team_id
    } = injured_reserve

    ir_position = get_roster_position(injured_player_id, team_id, "injured_reserve")
    replacement_position = get_roster_position(replacement_player_id, team_id, "active")

    injured_reserve
    |> Admin.return_injured_reserve(ir_position, replacement_position)
    |> Repo.transaction()
  end

  # Helpers

  defp get_roster_position(player_id, team_id, status) do
    clause = %{
      fantasy_player_id: player_id,
      fantasy_team_id: team_id,
      status: status
    }

    RosterPositions.get_by(clause)
  end
end
