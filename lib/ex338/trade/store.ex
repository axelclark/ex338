defmodule Ex338.Trade.Store do
  @moduledoc false

  alias Ex338.{Trade, TradeLineItem, Repo, Trade.Admin, RosterPosition}

  def all_for_league(league_id) do
    Trade
    |> Trade.by_league(league_id)
    |> Trade.preload_assocs()
    |> Trade.newest_first()
    |> Repo.all()
    |> Trade.count_votes()
  end

  def build_new_changeset() do
    Trade.new_changeset(trade_with_line_items())
  end

  def create_trade(attrs) do
    attrs =
      attrs
      |> filter_trade()
      |> build_trade_vote()

    %Trade{}
    |> Trade.new_changeset(attrs)
    |> Repo.insert()
  end

  def find!(id) do
    Trade
    |> Trade.preload_assocs()
    |> Repo.get!(id)
  end

  def load_line_items(trade) do
    Repo.preload(
      trade,
      trade_line_items: [
        :gaining_team,
        :losing_team,
        [fantasy_player: :sports_league]
      ]
    )
  end

  def maybe_update_for_league_vote(%Trade{status: "Proposed"} = trade) do
    teams = Trade.get_teams_from_trade(trade)
    %{trade_votes: votes} = trade
    votes = remove_uninvolved_votes(votes, teams)

    trade
    |> update_if_rejected(votes)
    |> update_if_accepted(votes, teams)
  end

  def maybe_update_for_league_vote(trade), do: trade

  def update_trade(trade_id, %{"status" => "Approved"} = attrs) do
    trade = find!(trade_id)

    case get_pos_from_trade(trade) do
      :error ->
        {:error, "One or more positions not found"}

      positions ->
        trade
        |> Admin.process_approved_trade(attrs, positions)
        |> Repo.transaction()
    end
  end

  def update_trade(trade_id, attrs) do
    trade =
      trade_id
      |> find!()
      |> Trade.changeset(attrs)

    case Repo.update(trade) do
      {:ok, trade} -> {:ok, %{trade: trade}}
      {:error, error} -> {:error, error}
    end
  end

  ## Helpers

  ## Implementations

  # build_new_changeset

  defp trade_with_line_items() do
    %Trade{
      trade_line_items: [
        %TradeLineItem{},
        %TradeLineItem{},
        %TradeLineItem{},
        %TradeLineItem{},
        %TradeLineItem{},
        %TradeLineItem{}
      ]
    }
  end

  # create_trade

  defp build_trade_vote(params) do
    trade_vote_params = %{
      "0" => %{
        "user_id" => params["submitted_by_user_id"],
        "fantasy_team_id" => params["submitted_by_team_id"],
        "approve" => true
      }
    }

    Map.put(params, "trade_votes", trade_vote_params)
  end

  defp filter_trade(trade) do
    {line_items, trade} = Map.pop(trade, "trade_line_items")

    line_items =
      line_items
      |> Enum.filter(&filter_line_items/1)
      |> Enum.into(%{})

    Map.put(trade, "trade_line_items", line_items)
  end

  def filter_line_items(
        {_,
         %{
           "fantasy_player_id" => nil,
           "gaining_team_id" => nil,
           "losing_team_id" => nil
         }}
      ) do
    false
  end

  def filter_line_items(_), do: true

  # maybe_update_for_league_vote

  def remove_uninvolved_votes(votes, teams) do
    Enum.filter(votes, fn vote ->
      Enum.any?(teams, &(&1.id == vote.fantasy_team_id))
    end)
  end

  defp update_if_rejected(trade, votes) do
    case any_reject_votes?(votes) do
      true ->
        trade
        |> Ecto.Changeset.change(status: "Rejected")
        |> Repo.update!()

      false ->
        trade
    end
  end

  defp any_reject_votes?(votes), do: Enum.any?(votes, &(&1.approve == false))

  defp update_if_accepted(%{status: "Rejected"} = trade, _votes, _teams), do: trade

  defp update_if_accepted(trade, votes, teams) do
    num_votes = Enum.count(votes)
    num_teams = Enum.count(teams)

    case(num_votes == num_teams) do
      true ->
        trade
        |> Ecto.Changeset.change(status: "Pending")
        |> Repo.update!()

      false ->
        trade
    end
  end

  # process_trade

  defp get_pos_from_trade(%{trade_line_items: line_items}) do
    positions = Enum.map(line_items, &query_pos_id/1)

    case Enum.any?(positions, &(&1 == nil)) do
      true -> :error
      false -> positions
    end
  end

  defp query_pos_id(item) do
    clause = %{
      fantasy_player_id: item.fantasy_player_id,
      fantasy_team_id: item.losing_team_id,
      status: "active"
    }

    RosterPosition.Store.get_by(clause)
  end
end
