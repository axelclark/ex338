defmodule Ex338Web.LayoutView do
  use Ex338Web, :view

  def display(fantasy_leagues, navbar) do
    fantasy_leagues
    |> filter_leagues(navbar)
    |> sort_by_div
    |> sort_by_year
    |> display_name
  end

  ## Helpers

  ## display

  defp filter_leagues(fantasy_leagues, navbar) do
    Enum.filter(fantasy_leagues, &(&1.navbar_display == navbar))
  end

  defp sort_by_year(fantasy_leagues) do
    Enum.sort_by(fantasy_leagues, & &1.year)
  end

  defp sort_by_div(fantasy_leagues) do
    Enum.sort_by(fantasy_leagues, & &1.division)
  end

  defp display_name(fantasy_leagues) do
    Enum.map(fantasy_leagues, fn league ->
      %{id: league.id, name: "#{league.year} Div #{league.division}"}
    end)
  end
end
