defmodule Ex338Web.PageView do
  use Ex338Web, :view

  def rules_path(fantasy_league) do
    case fantasy_league.draft_method do
      :redraft -> "#{fantasy_league.year}_rules.html"
      :keeper -> "#{fantasy_league.year}_keeper_rules.html"
    end
  end
end
