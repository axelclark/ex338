defmodule Ex338.TradeVoteTest do
  use Ex338.DataCase, async: true

  alias Ex338.TradeVote

  describe "changeset/2" do
    @valid_attrs %{
      trade_id: 1,
      fantasy_team_id: 2,
      user_id: 3,
      approve: false
    }
    test "valid with required attributes" do
      changeset = TradeVote.changeset(%TradeVote{}, @valid_attrs)
      assert changeset.valid?
    end

    @invalid_attrs %{}
    test "invalid without required attributes" do
      changeset = TradeVote.changeset(%TradeVote{}, @invalid_attrs)
      refute changeset.valid?
    end

    test "invalid if team already voted" do
      trade = insert(:trade)
      team = insert(:fantasy_team)
      user = insert(:user)
      other_user = insert(:user)
      insert(:trade_vote, user: user, trade: trade, fantasy_team: team)

      attrs = %{
        trade_id: trade.id,
        fantasy_team_id: team.id,
        user_id: other_user.id,
        approve: false
      }

      changeset = TradeVote.changeset(%TradeVote{}, attrs)
      {:error, changeset} = Repo.insert(changeset)

      refute changeset.valid?

      assert changeset.errors == [
               trade: {"Team has already voted", []}
             ]
    end
  end
end
