defmodule Ex338.TradeTest do
  use Ex338.DataCase, async: true

  alias Ex338.{Trade, TradeVote}

  describe "by_league/2" do
    test "returns trades from a league" do
      player = insert(:fantasy_player)
      player_b = insert(:fantasy_player)

      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "a", fantasy_league: league)
      team_b = insert(:fantasy_team, team_name: "b", fantasy_league: league)
      trade = insert(:trade)

      insert(
        :trade_line_item,
        gaining_team: team,
        losing_team: team_b,
        fantasy_player: player,
        trade: trade
      )

      league_b = insert(:fantasy_league)
      team_c = insert(:fantasy_team, team_name: "c", fantasy_league: league_b)
      team_d = insert(:fantasy_team, team_name: "d", fantasy_league: league_b)
      other_trade = insert(:trade)

      insert(
        :trade_line_item,
        gaining_team: team_c,
        losing_team: team_d,
        fantasy_player: player_b,
        trade: other_trade
      )

      result =
        Trade
        |> Trade.by_league(league.id)
        |> Repo.one()

      assert result.id == trade.id
    end
  end

  describe "changeset/2" do
    @valid_attrs %{}
    test "changeset requires no attributes and provides default status" do
      changeset = Trade.changeset(%Trade{}, @valid_attrs)
      assert changeset.valid?
      assert changeset.data.status == "Pending"
    end

    @invalid_attrs %{status: "pending"}
    test "changeset invalid when incorrect status option provided" do
      changeset = Trade.changeset(%Trade{}, @invalid_attrs)
      refute changeset.valid?
    end
  end

  describe "count_votes/1" do
    test "counts votes and updates a list of trades" do
      trades = [
        %Trade{
          trade_votes: [
            %TradeVote{approve: false},
            %TradeVote{approve: true},
            %TradeVote{approve: false}
          ]
        },
        %Trade{
          trade_votes: [
            %TradeVote{approve: false},
            %TradeVote{approve: true},
            %TradeVote{approve: true}
          ]
        }
      ]

      [trade1, trade2] = Trade.count_votes(trades)

      assert trade1.yes_votes == 1
      assert trade1.no_votes == 2
      assert trade2.yes_votes == 2
      assert trade2.no_votes == 1
    end

    test "counts votes and updates trade" do
      trade = %Trade{
        trade_votes: [
          %TradeVote{approve: false},
          %TradeVote{approve: true},
          %TradeVote{approve: false}
        ]
      }

      result = Trade.count_votes(trade)

      assert result.yes_votes == 1
      assert result.no_votes == 2
    end

    test "counts votes and updates trade with 0 votes if none submitted" do
      trade = %Trade{
        trade_votes: []
      }

      result = Trade.count_votes(trade)

      assert result.yes_votes == 0
      assert result.no_votes == 0
    end
  end

  describe "new_changeset/2" do
    @invalid_attrs %{}
    test "invalid without assoc to cast" do
      changeset = Trade.new_changeset(%Trade{}, @invalid_attrs)
      refute changeset.valid?
    end

    @invalid_attrs %{status: "pending"}
    test "invalid when incorrect status option provided" do
      changeset = Trade.new_changeset(%Trade{}, @invalid_attrs)
      refute changeset.valid?
    end

    test "valid when player is on losing teams' rosters" do
      user = insert(:user)
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      gaining_team = insert(:fantasy_team, fantasy_league: league)
      sport = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sport)
      insert(:championship, sports_league: sport)
      player = insert(:fantasy_player, sports_league: sport)
      insert(:roster_position, fantasy_team: team, fantasy_player: player)

      attrs = %{
        "submitted_by_user_id" => user.id,
        "submitted_by_team_id" => team.id,
        "additional_terms" => "more",
        "trade_line_items" => %{
          "0" => %{
            "fantasy_player_id" => player.id,
            "gaining_team_id" => gaining_team.id,
            "losing_team_id" => team.id
          }
        }
      }

      changeset = Trade.new_changeset(%Trade{}, attrs)

      assert changeset.valid?
    end

    test "invalid when player is not on losing teams' rosters" do
      user = insert(:user)
      team = insert(:fantasy_team)
      gaining_team = insert(:fantasy_team)
      player = insert(:fantasy_player)

      attrs = %{
        "additional_terms" => "more",
        "submitted_by_user_id" => user.id,
        "submitted_by_team_id" => team.id,
        "trade_line_items" => %{
          "0" => %{
            "fantasy_player_id" => player.id,
            "gaining_team_id" => gaining_team.id,
            "losing_team_id" => team.id
          }
        }
      }

      changeset = Trade.new_changeset(%Trade{}, attrs)

      refute changeset.valid?
    end
  end

  describe "preload_assocs/1" do
    test "returns trade with assocs" do
      sport = insert(:sports_league)
      player = insert(:fantasy_player, sports_league: sport)
      team_a = insert(:fantasy_team)
      team_b = insert(:fantasy_team)
      team_c = insert(:fantasy_team)
      user = insert(:user)
      trade = insert(:trade)

      insert(
        :trade_line_item,
        trade: trade,
        fantasy_player: player,
        gaining_team: team_a,
        losing_team: team_b
      )

      insert(:trade_vote, trade: trade, fantasy_team: team_c, user: user)

      %{trade_line_items: [line_item], trade_votes: [vote]} =
        Trade
        |> Trade.preload_assocs()
        |> Repo.one()

      assert line_item.fantasy_player.sports_league.id == sport.id
      assert line_item.gaining_team.id == team_a.id
      assert line_item.losing_team.id == team_b.id
      assert vote.fantasy_team.id == team_c.id
    end
  end
end
