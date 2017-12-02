defmodule Ex338.User.Store do
  @moduledoc false

  alias Ex338.{User, Owner, Repo}

  def get_admin_emails() do
    Repo.all(User.admin_emails)
  end

  def get_league_and_admin_emails(league_id) do
    admins = get_admin_emails()
    owners = Owner.Store.get_email_recipients_for_league(league_id)
    Enum.uniq(owners ++ admins)
  end
end
