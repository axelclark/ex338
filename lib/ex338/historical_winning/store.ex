defmodule Ex338.HistoricalWinning.Store do
  @moduledoc false

  alias Ex338.{HistoricalWinning, Repo}

  def get_all_winnings() do
    Repo.all(HistoricalWinning)
  end
end
