defmodule Ex338Web.ExAdmin.Championship do
  @moduledoc false

  use ExAdmin.Register

  register_resource Ex338.Championship do
    form championship do
      inputs do
        input(championship, :title)
        input(championship, :sports_league, collection: Ex338.SportsLeague.all())
        input(championship, :category, collection: Ex338.Championship.categories())
        input(championship, :overall, collection: Ex338.Championship.all())
        input(championship, :trade_deadline_at)
        input(championship, :waiver_deadline_at)
        input(championship, :championship_at)
        input(championship, :year)
        input(championship, :in_season_draft)
      end
    end
  end
end
