defmodule Ex338.TradeLineItem do
  @moduledoc false

  use Ex338Web, :model

  alias Ex338.{RosterPosition}

  schema "trade_line_items" do
    belongs_to :trade, Ex338.Trade
    belongs_to :losing_team, Ex338.FantasyTeam
    belongs_to :fantasy_player, Ex338.FantasyPlayer
    belongs_to :gaining_team, Ex338.FantasyTeam

    timestamps()
  end

  def assoc_changeset(line_item, params \\ %{}) do
    line_item
    |> cast(params, [:fantasy_player_id, :losing_team_id, :gaining_team_id])
    |> validate_required([:fantasy_player_id, :losing_team_id, :gaining_team_id])
    |> validate_player_on_roster
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(line_item, params \\ %{}) do
    line_item
    |> cast(params, [:trade_id, :fantasy_player_id, :losing_team_id,
                     :gaining_team_id])
    |> validate_required([:trade_id, :fantasy_player_id,
                          :losing_team_id, :gaining_team_id])
  end

  ## Helpers

  ## assoc_changeset

  defp validate_player_on_roster(
    %{
      changes: %{
        losing_team_id: team_id, fantasy_player_id: player_id
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
      :fantasy_player_id, "Player not on losing team's roster"
    )
  end

  defp add_player_on_roster_error(line_item_changeset, _active_position) do
    line_item_changeset
  end
end
