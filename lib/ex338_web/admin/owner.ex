defmodule Ex338Web.ExAdmin.Owner do
  @moduledoc false
  use ExAdmin.Register

  alias Ex338.{FantasyTeams.FantasyTeam, Repo, User}

  register_resource Ex338.Owner do
    form owner do
      inputs do
        input(
          owner,
          :fantasy_team,
          collection: Repo.all(FantasyTeam.alphabetical(FantasyTeam)),
          fields: [:team_name, :id]
        )

        input(owner, :user, collection: Repo.all(User.alphabetical(User)))
        input(owner, :rules)
      end
    end
  end
end
