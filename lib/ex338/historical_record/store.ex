defmodule Ex338.HistoricalRecord.Store do
  @moduledoc false

  alias Ex338.{HistoricalRecord, Repo}

  def get_current_all_time_records() do
    HistoricalRecord
    |> HistoricalRecord.all_time_records()
    |> HistoricalRecord.current_records()
    |> HistoricalRecord.sorted_by_order()
    |> Repo.all()
  end

  def get_current_season_records() do
    HistoricalRecord
    |> HistoricalRecord.season_records()
    |> HistoricalRecord.current_records()
    |> HistoricalRecord.sorted_by_order()
    |> Repo.all()
  end
end
