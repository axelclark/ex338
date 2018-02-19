defmodule Ex338.TradeLineItemTest do
  use Ex338.DataCase, aysnc: true

  import Ex338.CalendarAssistant

  alias Ex338.TradeLineItem

  @valid_attrs %{gaining_team_id: 12, fantasy_player_id: 5, losing_team_id: 3}
  describe "assoc_changeset/2" do
    test "changeset with valid attributes" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      gaining_team = insert(:fantasy_team, fantasy_league: league)
      sport = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sport)

      insert(
        :championship,
        sports_league: sport,
        trade_deadline_at: days_from_now(30)
      )

      player = insert(:fantasy_player, sports_league: sport)
      insert(:roster_position, fantasy_team: team, fantasy_player: player)

      attrs = %{
        "fantasy_player_id" => player.id,
        "gaining_team_id" => gaining_team.id,
        "losing_team_id" => team.id
      }

      changeset = TradeLineItem.assoc_changeset(%TradeLineItem{}, attrs)

      assert changeset.valid?
    end

    test "invalid when player is not on losing teams' rosters" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      gaining_team = insert(:fantasy_team, fantasy_league: league)
      sport = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sport)

      insert(
        :championship,
        sports_league: sport,
        trade_deadline_at: days_from_now(30)
      )

      player = insert(:fantasy_player, sports_league: sport)

      attrs = %{
        "fantasy_player_id" => player.id,
        "gaining_team_id" => gaining_team.id,
        "losing_team_id" => team.id
      }

      changeset = TradeLineItem.assoc_changeset(%TradeLineItem{}, attrs)

      refute changeset.valid?

      assert changeset.errors == [
               fantasy_player_id: {"Player not on losing team's roster", []}
             ]
    end

    test "invalid when trade deadline has passed for a player" do
      league = insert(:fantasy_league, year: 2017)
      team = insert(:fantasy_team, fantasy_league: league)
      gaining_team = insert(:fantasy_team, fantasy_league: league)
      sport = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sport)

      insert(
        :championship,
        sports_league: sport,
        trade_deadline_at: days_from_now(-30),
        year: 2017
      )

      player = insert(:fantasy_player, sports_league: sport)
      insert(:roster_position, fantasy_team: team, fantasy_player: player)

      attrs = %{
        "fantasy_player_id" => player.id,
        "gaining_team_id" => gaining_team.id,
        "losing_team_id" => team.id
      }

      changeset = TradeLineItem.assoc_changeset(%TradeLineItem{}, attrs)

      refute changeset.valid?

      assert changeset.errors == [
               fantasy_player_id: {"Trade submitted after trade deadline.", []}
             ]
    end

    @invalid_attrs %{}
    test "changeset with invalid attributes" do
      changeset = TradeLineItem.assoc_changeset(%TradeLineItem{}, @invalid_attrs)
      refute changeset.valid?
    end
  end

  describe "changeset/2" do
    @valid_attrs %{
      trade_id: 1,
      gaining_team_id: 12,
      fantasy_player_id: 5,
      losing_team_id: 3
    }
    test "changeset with valid attributes" do
      changeset = TradeLineItem.changeset(%TradeLineItem{}, @valid_attrs)
      assert changeset.valid?
    end

    @invalid_attrs %{
      gaining_team_id: 12,
      fantasy_player_id: 5,
      losing_team_id: 3
    }
    test "changeset with invalid attributes" do
      changeset = TradeLineItem.changeset(%TradeLineItem{}, @invalid_attrs)
      refute changeset.valid?
    end
  end
end
