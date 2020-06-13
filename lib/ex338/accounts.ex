defmodule Ex338.Accounts do
  @moduledoc false

  alias Ex338.{FantasyTeams.FantasyTeam, Accounts.User, FantasyTeams, Repo}

  def get_admin_emails() do
    Repo.all(User.admin_emails())
  end

  def get_league_and_admin_emails(league_id) do
    admins = get_admin_emails()
    owners = FantasyTeams.get_email_recipients_for_league(league_id)
    Enum.uniq(owners ++ admins)
  end

  def get_user!(user_id) do
    User
    |> User.preload_assocs()
    |> Repo.get!(user_id)
  end

  def preload_team_by_league(%User{} = user, league_id) do
    Repo.preload(
      user,
      fantasy_teams: FantasyTeam.by_league(FantasyTeam, league_id)
    )
  end

  def update_user(user, params) do
    user
    |> User.user_changeset(params)
    |> Repo.update()
  end
end
