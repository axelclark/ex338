defmodule Ex338.Trades.TradeLineItem do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias Ex338.DraftPicks
  alias Ex338.FantasyPlayers
  alias Ex338.FantasyTeams
  alias Ex338.RosterPositions

  schema "trade_line_items" do
    belongs_to(:trade, Ex338.Trades.Trade)
    belongs_to(:losing_team, Ex338.FantasyTeams.FantasyTeam)
    belongs_to(:fantasy_player, Ex338.FantasyPlayers.FantasyPlayer)
    belongs_to(:future_pick, Ex338.DraftPicks.FuturePick)
    belongs_to(:gaining_team, Ex338.FantasyTeams.FantasyTeam)

    timestamps()
  end

  def assoc_changeset(line_item, params \\ %{}) do
    line_item
    |> cast(params, [:fantasy_player_id, :future_pick_id, :losing_team_id, :gaining_team_id])
    |> validate_required([:losing_team_id, :gaining_team_id])
    |> validate_player_on_roster()
    |> validate_future_pick_owner()
    |> validate_trade_deadline()
    |> check_constraint(
      :fantasy_player_id,
      name: :one_asset_per_line_item,
      message: "Line items should only include 1 player or 1 future pick"
    )
    |> check_constraint(
      :future_pick_id,
      name: :one_asset_per_line_item,
      message: "Line items should only include 1 player or 1 future pick"
    )
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(line_item, params \\ %{}) do
    line_item
    |> cast(params, [
      :trade_id,
      :fantasy_player_id,
      :future_pick_id,
      :losing_team_id,
      :gaining_team_id
    ])
    |> validate_required([:trade_id, :losing_team_id, :gaining_team_id])
    |> check_constraint(
      :fantasy_player_id,
      name: :one_asset_per_line_item,
      message: "Line items should only include 1 player or 1 future pick"
    )
    |> check_constraint(
      :future_pick_id,
      name: :one_asset_per_line_item,
      message: "Line items should only include 1 player or 1 future pick"
    )
  end

  ## Helpers

  ## assoc_changeset

  defp validate_player_on_roster(
         %{changes: %{losing_team_id: team_id, fantasy_player_id: player_id}} = changeset
       )
       when not is_nil(player_id) do
    result =
      RosterPositions.get_by(
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
    league_id = FantasyTeams.find(team_id).fantasy_league_id

    case FantasyPlayers.get_next_championship(
           FantasyPlayers.FantasyPlayer,
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

  defp validate_future_pick_owner(
         %{changes: %{losing_team_id: team_id, future_pick_id: pick_id}} = changeset
       )
       when not is_nil(pick_id) do
    result =
      DraftPicks.get_future_pick_by(
        current_team_id: team_id,
        id: pick_id
      )

    add_future_pick_owner_error(changeset, result)
  end

  defp validate_future_pick_owner(changeset), do: changeset

  defp add_future_pick_owner_error(line_item_changeset, nil) do
    add_error(
      line_item_changeset,
      :future_pick_id,
      "Future pick not currently owned by losing team"
    )
  end

  defp add_future_pick_owner_error(line_item_changeset, _active_position) do
    line_item_changeset
  end
end
