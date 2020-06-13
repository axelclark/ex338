defmodule Ex338.AnnualLeagueSetup.InitialData do
  @moduledoc """
  Script for populating the database. You can run it as:

      mix run priv/repo/annual_league_setup/initial_data.exs

  Inside the script, you can read and write to any of your
  repositories directly:

      Ex338.Repo.insert!(%Ex338.SomeModel{})

  We recommend using the bang functions (`insert!`, `update!`
  and so on) as they will fail if something goes wrong.

  To substitue hidden characters in VIM %s/<ctr>v<ctrl>m/\r/g
  """

  alias Ex338.{
    FantasyPlayers.FantasyPlayer,
    FantasyTeams.FantasyTeam,
    Repo,
    Championships.Championship,
    LeagueSport,
    Owner
  }

  def store_championships(row) do
    changeset = Championship.changeset(%Championship{}, row)
    Repo.insert!(changeset)
  end

  def store_fantasy_players(row) do
    changeset = FantasyPlayer.changeset(%FantasyPlayer{}, row)
    Repo.insert!(changeset)
  end

  def store_fantasy_teams(row) do
    changeset = FantasyTeam.changeset(%FantasyTeam{}, row)
    Repo.insert!(changeset)
  end

  def store_league_sports(row) do
    changeset = LeagueSport.changeset(%LeagueSport{}, row)
    Repo.insert!(changeset)
  end

  def store_owners(row) do
    changeset = Owner.changeset(%Owner{}, row)
    Repo.insert!(changeset)
  end
end

File.stream!("priv/repo/annual_league_setup/data/championships.csv")
|> Stream.drop(1)
|> CSV.decode!(
  headers: [
    :projected_id,
    :title,
    :category,
    :waiver_deadline_at,
    :trade_deadline_at,
    :championship_at,
    :sports_league_id,
    :overall_id,
    :in_season_draft,
    :year
  ]
)
|> Enum.each(&Ex338.AnnualLeagueSetup.InitialData.store_championships/1)

File.stream!("priv/repo/annual_league_setup/data/league_sports.csv")
|> Stream.drop(1)
|> CSV.decode!(headers: [:fantasy_league_id, :sports_league_id])
|> Enum.each(&Ex338.AnnualLeagueSetup.InitialData.store_league_sports/1)

File.stream!("priv/repo/annual_league_setup/data/fantasy_players.csv")
|> Stream.drop(1)
|> CSV.decode!(headers: [:projected_id, :player_name, :draft_pick, :sports_league_id])
|> Enum.each(&Ex338.AnnualLeagueSetup.InitialData.store_fantasy_players/1)

File.stream!("priv/repo/annual_league_setup/data/fantasy_teams.csv")
|> Stream.drop(1)
|> CSV.decode!(
  headers: [
    :projected_id,
    :team_name,
    :waiver_position,
    :winnings_adj,
    :dues_paid,
    :winnings_received,
    :commish_notes,
    :fantasy_league_id
  ]
)
|> Enum.each(&Ex338.AnnualLeagueSetup.InitialData.store_fantasy_teams/1)

File.stream!("priv/repo/annual_league_setup/data/owners.csv")
|> Stream.drop(1)
|> CSV.decode!(headers: [:fantasy_team_id, :team_name, :last_year_team, :user_id])
|> Enum.each(&Ex338.AnnualLeagueSetup.InitialData.store_owners/1)
