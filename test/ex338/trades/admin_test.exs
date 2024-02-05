defmodule Ex338.Trades.AdminTest do
  use Ex338.DataCase, async: true

  alias Ecto.Multi
  alias Ex338.DraftPicks
  alias Ex338.RosterPositions.RosterPosition
  alias Ex338.Trades.Admin
  alias Ex338.Trades.Trade
  alias Ex338.Trades.TradeLineItem

  @trade %Trade{
    status: "Pending",
    trade_line_items: [
      %TradeLineItem{
        losing_team_id: 1,
        fantasy_player_id: 2,
        gaining_team_id: 3
      },
      %TradeLineItem{
        losing_team_id: 1,
        future_pick_id: 4,
        gaining_team_id: 3,
        future_pick: %DraftPicks.FuturePick{
          id: 4,
          round: 1,
          current_team_id: 1,
          original_team_id: 1
        }
      }
    ]
  }

  @positions [
    %RosterPosition{
      id: 4,
      fantasy_team_id: 1,
      fantasy_player_id: 2,
      status: "active"
    }
  ]

  describe "process_approved_trade/3" do
    test "with Approved status, returns a multi with valid changeset" do
      params = %{"status" => "Approved"}

      multi = Admin.process_approved_trade(@trade, params, @positions)

      assert [
               {:trade, {:update, trade_changeset, []}},
               {:losing_position_4, {:update, los_pos_changeset, []}},
               {:gaining_position_2, {:insert, gain_pos_changeset, []}},
               {:future_pick_4, {:update, future_pick_changeset, []}}
             ] = Multi.to_list(multi)

      assert trade_changeset.valid?
      assert los_pos_changeset.valid?
      assert gain_pos_changeset.valid?
      assert future_pick_changeset.valid?
    end
  end
end
