defmodule Ex338.TradeTest do
  use Ex338.DataCase, async: true

  alias Ex338.{Trade, TradeVote}

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
end
