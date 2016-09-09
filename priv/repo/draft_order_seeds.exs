# Script for populating the database. You can run it as:
#
#     mix run priv/repo/dev_seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Ex338.Repo.insert!(%Ex338.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
#
# To substitue hidden characters in VIM %s/<ctr>v<ctrl>m/\r/g

alias Ex338.{DraftPick, Repo}

defmodule Ex338.DraftOrderSeeds do
  def store_draft_picks(row) do
    changeset = DraftPick.changeset(%DraftPick{}, row)
    Repo.insert!(changeset)
  end
end

Ex338.Repo.delete_all(DraftPick)

File.stream!("priv/repo/csv_seed_data/draft_picks.csv")
  |> Stream.drop(1)
  |> CSV.decode(headers: [:draft_position, :fantasy_league_id, :fantasy_team_id])
  |> Enum.each(&Ex338.DraftOrderSeeds.store_draft_picks/1)
