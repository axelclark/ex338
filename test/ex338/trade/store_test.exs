defmodule Ex338.Trade.StoreTest do
  use Ex338.DataCase
  alias Ex338.Trade.Store

  describe "all_for_league/2" do
    test "returns only trades from a league with most recent first" do
      player = insert(:fantasy_player)
      player_b = insert(:fantasy_player)

      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "a", fantasy_league: league)
      team_b = insert(:fantasy_team, team_name: "b", fantasy_league: league)
      team_c = insert(:fantasy_team, team_name: "c", fantasy_league: league)

      trade1 = insert(:trade)

      insert(
        :trade_line_item,
        gaining_team: team,
        losing_team: team_b,
        fantasy_player: player,
        trade: trade1
      )

      trade2 = insert(:trade)

      insert(
        :trade_line_item,
        gaining_team: team_b,
        losing_team: team_c,
        fantasy_player: player_b,
        trade: trade2
      )

      league_b = insert(:fantasy_league)
      team_d = insert(:fantasy_team, team_name: "d", fantasy_league: league_b)
      team_e = insert(:fantasy_team, team_name: "e", fantasy_league: league_b)
      other_trade = insert(:trade)

      insert(
        :trade_line_item,
        gaining_team: team_e,
        losing_team: team_d,
        fantasy_player: player_b,
        trade: other_trade
      )

      [result_a, result_b] = Store.all_for_league(league.id)
      trades = [trade1.id, trade2.id]

      assert result_a.id in trades
      assert result_b.id in trades
    end
  end

  describe "build_new_changeset/0" do
    test "creates a trade changeset with line items" do
      changeset = Store.build_new_changeset()

      assert changeset.valid? == true
      assert Enum.count(changeset.data.trade_line_items) == 6
    end
  end

  describe "create_trade/1" do
    test "creates a trade with line items" do
      user = insert(:user)
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      team_b = insert(:fantasy_team, fantasy_league: league)
      sport = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sport)
      insert(:championship, sports_league: sport)
      player_a = insert(:fantasy_player, sports_league: sport)
      player_b = insert(:fantasy_player, sports_league: sport)
      player_c = insert(:fantasy_player, sports_league: sport)
      player_d = insert(:fantasy_player, sports_league: sport)
      insert(:roster_position, fantasy_player: player_a, fantasy_team: team)
      insert(:roster_position, fantasy_player: player_b, fantasy_team: team_b)
      insert(:roster_position, fantasy_player: player_c, fantasy_team: team)
      insert(:roster_position, fantasy_player: player_d, fantasy_team: team_b)

      attrs = %{
        "submitted_by_user_id" => user.id,
        "submitted_by_team_id" => team.id,
        "additional_terms" => "more",
        "trade_line_items" => %{
          "0" => %{
            "fantasy_player_id" => player_a.id,
            "gaining_team_id" => team_b.id,
            "losing_team_id" => team.id
          },
          "1" => %{
            "fantasy_player_id" => player_b.id,
            "gaining_team_id" => team.id,
            "losing_team_id" => team_b.id
          },
          "2" => %{
            "fantasy_player_id" => player_c.id,
            "gaining_team_id" => team_b.id,
            "losing_team_id" => team.id
          },
          "3" => %{
            "fantasy_player_id" => player_d.id,
            "gaining_team_id" => team.id,
            "losing_team_id" => team_b.id
          }
        }
      }

      {:ok, result} = Store.create_trade(attrs)

      assert result.additional_terms == "more"
    end

    test "creates a trade with less than four line items" do
      user = insert(:user)
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      team_b = insert(:fantasy_team, fantasy_league: league)
      sport = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sport)
      insert(:championship, sports_league: sport)
      player_a = insert(:fantasy_player, sports_league: sport)
      player_b = insert(:fantasy_player, sports_league: sport)
      insert(:roster_position, fantasy_player: player_a, fantasy_team: team)
      insert(:roster_position, fantasy_player: player_b, fantasy_team: team_b)

      attrs = %{
        "submitted_by_user_id" => user.id,
        "submitted_by_team_id" => team.id,
        "additional_terms" => "more",
        "trade_line_items" => %{
          "0" => %{
            "fantasy_player_id" => player_a.id,
            "gaining_team_id" => team_b.id,
            "losing_team_id" => team.id
          },
          "1" => %{
            "fantasy_player_id" => player_b.id,
            "gaining_team_id" => team.id,
            "losing_team_id" => team_b.id
          },
          "2" => %{
            "fantasy_player_id" => nil,
            "gaining_team_id" => nil,
            "losing_team_id" => nil
          },
          "3" => %{
            "fantasy_player_id" => nil,
            "gaining_team_id" => nil,
            "losing_team_id" => nil
          }
        }
      }

      {:ok, result} = Store.create_trade(attrs)

      assert result.additional_terms == "more"
    end
  end

  describe "load_line_items/1" do
    test "loads associations on a trade struct" do
      user = insert(:user)
      sport = insert(:sports_league)
      player = insert(:fantasy_player, sports_league: sport)
      team_a = insert(:fantasy_team)
      team_b = insert(:fantasy_team)
      trade = insert(:trade, submitted_by_user: user, submitted_by_team: team_a)

      insert(
        :trade_line_item,
        trade: trade,
        gaining_team: team_a,
        losing_team: team_b,
        fantasy_player: player
      )

      trade = %{trade_line_items: [result]} = Store.load_line_items(trade)

      assert trade.submitted_by_team.team_name == team_a.team_name
      assert trade.submitted_by_user.email == user.email
      assert result.fantasy_player.sports_league.id == sport.id
      assert result.gaining_team.id == team_a.id
      assert result.losing_team.id == team_b.id
    end
  end

  describe "process_trade/2" do
    test "updates repo with successful trade " do
      league = insert(:fantasy_league)

      team_a = insert(:fantasy_team, fantasy_league: league)
      player_a = insert(:fantasy_player)
      insert(:roster_position, fantasy_team: team_a, fantasy_player: player_a)

      team_b = insert(:fantasy_team, fantasy_league: league)
      player_b = insert(:fantasy_player)
      insert(:roster_position, fantasy_team: team_b, fantasy_player: player_b)

      trade = insert(:trade)

      insert(
        :trade_line_item,
        gaining_team: team_b,
        losing_team: team_a,
        fantasy_player: player_a,
        trade: trade
      )

      insert(
        :trade_line_item,
        gaining_team: team_a,
        losing_team: team_b,
        fantasy_player: player_b,
        trade: trade
      )

      params = %{"status" => "Approved"}

      {:ok, %{trade: trade}} = Store.process_trade(trade.id, params)

      assert trade.status == "Approved"

      positions = Repo.all(Ex338.RosterPosition)
      assert Enum.count(positions) == 4

      new_positions = Enum.filter(positions, &(&1.status == "active"))
      assert Enum.map(new_positions, & &1.acq_method) == ["trade", "trade"]
    end

    test "returns error if a position is not found" do
      league = insert(:fantasy_league)

      team_a = insert(:fantasy_team, fantasy_league: league)
      player_a = insert(:fantasy_player)
      insert(:roster_position, fantasy_team: team_a, fantasy_player: player_a)

      team_b = insert(:fantasy_team, fantasy_league: league)
      player_b = insert(:fantasy_player)

      trade = insert(:trade)

      insert(
        :trade_line_item,
        gaining_team: team_b,
        losing_team: team_a,
        fantasy_player: player_a,
        trade: trade
      )

      insert(
        :trade_line_item,
        gaining_team: team_a,
        losing_team: team_b,
        fantasy_player: player_b,
        trade: trade
      )

      params = %{"status" => "Approved"}

      {:error, error} = Store.process_trade(trade.id, params)

      assert error == "One or more positions not found"
    end
  end

  describe "find!/1" do
    test "returns a Trade with assocs loaded" do
      trade = insert(:trade)
      line_item = insert(:trade_line_item, trade: trade)

      result = %{trade_line_items: [item]} = Store.find!(trade.id)

      assert result.id == trade.id
      assert item.id == line_item.id
    end
  end
end
