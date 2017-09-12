# Script for populating the database. You can run it as:
#
#     mix run priv/repo/setup_2018/data2.exs
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

defmodule Ex338.Setup2018.Data2 do
  @moduledoc false

  alias Ex338.{Repo, Owner, DraftPick}

  def store_owners(row) do
    changeset = Owner.changeset(%Owner{}, row)
    Repo.insert!(changeset)
  end

  def store_draft_picks(row) do
    changeset = DraftPick.changeset(%DraftPick{}, row)
    Repo.insert!(changeset)
  end
end

File.stream!("priv/repo/setup_2018/data/2018_owners.csv")
  |> Stream.drop(1)
  |> CSV.decode!(headers: [:fantasy_team_id, :user_id])
  |> Enum.each(&Ex338.Setup2018.Data2.store_owners/1)

File.stream!("priv/repo/setup_2018/data/2018_draft_picks.csv")
  |> Stream.drop(1)
  |> CSV.decode!(headers: [:draft_position, :fantasy_league_id, :fantasy_team_id,
                          :fantasy_team_name])
  |> Enum.each(&Ex338.Setup2018.Data2.store_draft_picks/1)
