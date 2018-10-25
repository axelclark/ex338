defmodule Ex338.HistoricalWinning.Store do
  @moduledoc false

  alias Ex338.{HistoricalWinning, Repo}

  def get_all_winnings() do
    HistoricalWinning
    |> HistoricalWinning.order_by_amount()
    |> Repo.all()
  end
end
