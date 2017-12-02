defmodule Ex338.TradeTest do
  use Ex338.DataCase, async: true

  alias Ex338.Trade

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
      team = insert(:fantasy_team)
      gaining_team = insert(:fantasy_team)
      player = insert(:fantasy_player)
      insert(:roster_position, fantasy_team: team, fantasy_player: player)
      attrs = %{
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
      team = insert(:fantasy_team)
      gaining_team = insert(:fantasy_team)
      player = insert(:fantasy_player)
      attrs = %{
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

      refute changeset.valid?
    end
  end
end
