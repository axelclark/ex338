defmodule Ex338Web.LayoutView do
  use Ex338Web, :view

  def display(fantasy_leagues, navbar, draft_method \\ :redraft) do
    fantasy_leagues
    |> filter_by_navbar(navbar)
    |> filter_by_draft_method(draft_method)
    |> sort_by_div
    |> sort_by_year
  end

  ## Helpers

  ## display

  defp filter_by_draft_method(fantasy_leagues, draft_method) do
    Enum.filter(fantasy_leagues, &(&1.draft_method == draft_method))
  end

  defp filter_by_navbar(fantasy_leagues, navbar) do
    Enum.filter(fantasy_leagues, &(&1.navbar_display == navbar))
  end

  defp sort_by_div(fantasy_leagues) do
    Enum.sort_by(fantasy_leagues, & &1.division)
  end

  defp sort_by_year(fantasy_leagues) do
    Enum.sort_by(fantasy_leagues, & &1.year, &>=/2)
  end
end
