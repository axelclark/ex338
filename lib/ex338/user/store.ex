defmodule Ex338.User.Store do
  @moduledoc false

  alias Ex338.{FantasyTeam, User, Owner, Repo}

  def get_admin_emails() do
    Repo.all(User.admin_emails)
  end

  def get_league_and_admin_emails(league_id) do
    admins = get_admin_emails()
    owners = Owner.Store.get_email_recipients_for_league(league_id)
    Enum.uniq(owners ++ admins)
  end

  def preload_team_by_league(%User{} = user, league_id) do
    Repo.preload(
      user,
      [fantasy_teams: FantasyTeam.by_league(FantasyTeam, league_id)]
    )
  end
end
