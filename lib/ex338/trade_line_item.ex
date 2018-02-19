defmodule Ex338.TradeLineItem do
  @moduledoc false

  use Ex338Web, :model

  alias Ex338.{RosterPosition, FantasyTeam, FantasyPlayer}

  schema "trade_line_items" do
    belongs_to(:trade, Ex338.Trade)
    belongs_to(:losing_team, Ex338.FantasyTeam)
    belongs_to(:fantasy_player, Ex338.FantasyPlayer)
    belongs_to(:gaining_team, Ex338.FantasyTeam)

    timestamps()
  end

  def assoc_changeset(line_item, params \\ %{}) do
    line_item
    |> cast(params, [:fantasy_player_id, :losing_team_id, :gaining_team_id])
    |> validate_required([:fantasy_player_id, :losing_team_id, :gaining_team_id])
    |> validate_player_on_roster
    |> validate_trade_deadline
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(line_item, params \\ %{}) do
    line_item
    |> cast(params, [:trade_id, :fantasy_player_id, :losing_team_id, :gaining_team_id])
    |> validate_required([:trade_id, :fantasy_player_id, :losing_team_id, :gaining_team_id])
  end

  ## Helpers

  ## assoc_changeset

  defp validate_player_on_roster(
         %{
           changes: %{
             losing_team_id: team_id,
             fantasy_player_id: player_id
           }
         } = changeset
       ) do
    result =
      RosterPosition.Store.get_by(
        fantasy_team_id: team_id,
        fantasy_player_id: player_id,
        status: "active"
      )

    add_player_on_roster_error(changeset, result)
  end

  defp validate_player_on_roster(changeset), do: changeset

  defp add_player_on_roster_error(line_item_changeset, nil) do
    add_error(
      line_item_changeset,
      :fantasy_player_id,
      "Player not on losing team's roster"
    )
  end

  defp add_player_on_roster_error(line_item_changeset, _active_position) do
    line_item_changeset
  end

  defp validate_trade_deadline(%{changes: %{fantasy_player_id: player_id}} = changeset)
       when not is_nil(player_id) do
    do_validate_trade_deadline(changeset, player_id)
  end

  defp validate_trade_deadline(changeset), do: changeset

  defp do_validate_trade_deadline(changeset, player_id) do
    team_id = get_field(changeset, :gaining_team_id)
    league_id = FantasyTeam.Store.find(team_id).fantasy_league_id

    case FantasyPlayer.Store.get_next_championship(
           FantasyPlayer,
           player_id,
           league_id
         ) do
      nil ->
        add_error(
          changeset,
          :fantasy_player_id,
          "Trade submitted after trade deadline."
        )

      championship ->
        add_error_for_trade_deadline(
          changeset,
          championship.trade_deadline_at
        )
    end
  end

  defp add_error_for_trade_deadline(changeset, trade_deadline) do
    now = DateTime.utc_now()

    case DateTime.compare(trade_deadline, now) do
      :gt ->
        changeset

      :eq ->
        changeset

      :lt ->
        add_error(
          changeset,
          :fantasy_player_id,
          "Trade submitted after trade deadline."
        )
    end
  end
end
