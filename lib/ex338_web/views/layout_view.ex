defmodule Ex338Web.LayoutView do
  use Ex338Web, :view

  def display(fantasy_leagues, navbar) do
    fantasy_leagues
    |> filter_leagues(navbar)
    |> sort_by_div
    |> sort_by_year
  end

  ## Helpers

  ## display

  defp filter_leagues(fantasy_leagues, navbar) do
    Enum.filter(fantasy_leagues, &(&1.navbar_display == navbar))
  end

  defp sort_by_div(fantasy_leagues) do
    Enum.sort_by(fantasy_leagues, & &1.division)
  end

  defp sort_by_year(fantasy_leagues) do
    Enum.sort_by(fantasy_leagues, & &1.year)
  end
end
