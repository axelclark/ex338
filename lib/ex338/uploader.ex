defmodule Ex338.Uploader do
  @moduledoc false

  alias Ecto.{Multi}
  alias Ex338.{Repo}

  @table_options [
    "Championships.Championship",
    "ChampionshipResult",
    "DraftPick",
    "FantasyLeagues.FantasyLeague",
    "FantasyPlayers.FantasyPlayer",
    "FantasyTeams.FantasyTeam",
    "InSeasonDraftPick",
    "LeagueSport",
    "Owner",
    "RosterPositions.RosterPosition",
    "SportsLeague"
  ]

  def build_inserts_from_rows(rows, table) do
    module = Module.safe_concat([Ex338, table])
    {multi, _num_rows} = Enum.reduce(rows, {Multi.new(), 1}, &build_insert(&1, &2, module))
    multi
  end

  def insert_from_csv(file_path, table) do
    file_path
    |> File.stream!()
    |> format_text()
    |> CSV.decode!(headers: true)
    |> build_inserts_from_rows(table)
    |> Repo.transaction()
  end

  def table_options, do: @table_options

  ## Helpers

  ## build_inserts_from_rows

  defp build_insert(row, {multi, num}, module) do
    changeset =
      module
      |> struct()
      |> module.changeset(row)

    multi = Multi.insert(multi, {module, num}, changeset)

    {multi, num + 1}
  end

  ## insert_from_csv

  defp format_text(file_stream) do
    file_stream
    |> Stream.map(&String.replace(&1, "FALSE", "false"))
    |> Stream.map(&String.replace(&1, "TRUE", "true"))
  end
end
