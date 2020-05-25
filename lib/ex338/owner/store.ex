defmodule Ex338.Owner.Store do
  @moduledoc false

  alias Ex338.{Owner, Repo}

  def get_leagues_email_addresses(leagues) do
    Enum.reduce(leagues, [], fn league, acc ->
      addresses = get_email_recipients_for_league(league)
      addresses ++ acc
    end)
  end

  def get_email_recipients_for_league(league_id) do
    Owner
    |> Owner.email_recipients_for_league(league_id)
    |> Repo.all()
  end

  def update_owner(%Owner{} = owner, attrs) do
    owner
    |> Owner.changeset(attrs)
    |> Repo.update()
  end
end
