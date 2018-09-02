defmodule Ex338.AnnualLeagueSetup.DraftData do
  @moduledoc """
  Script for populating the database. You can run it as:

      mix run priv/repo/annual_league_setup/draft_data.exs

  Inside the script, you can read and write to any of your
  repositories directly:

      Ex338.Repo.insert!(%Ex338.SomeModel{})

  We recommend using the bang functions (`insert!`, `update!`
  and so on) as they will fail if something goes wrong.

  To substitue hidden characters in VIM %s/<ctr>v<ctrl>m/\r/g
  """

  alias Ex338.{Repo, DraftPick}

  def store_draft_picks(row) do
    changeset = DraftPick.changeset(%DraftPick{}, row)
    Repo.insert!(changeset)
  end
end

File.stream!("priv/repo/annual_league_setup/data/draft_picks.csv")
  |> Stream.drop(1)
  |> CSV.decode!(headers: [:draft_position, :fantasy_league_id, :fantasy_team_id,
                          :fantasy_team_name])
  |> Enum.each(&Ex338.AnnualLeagueSetup.DraftData.store_draft_picks/1)
