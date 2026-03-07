defmodule Ex338Web.FantasyTeamHTML do
  use Ex338Web, :html

  import Ex338Web.FantasyTeamComponents

  def index(assigns) do
    owned_teams = Enum.filter(assigns.fantasy_teams, &owner?(assigns.current_user, &1))
    other_teams = Enum.reject(assigns.fantasy_teams, &owner?(assigns.current_user, &1))

    assigns =
      assigns
      |> Map.put(:owned_teams, owned_teams)
      |> Map.put(:other_teams, other_teams)

    ~H"""
    <div class="space-y-6">
      <div class="space-y-1">
        <p class="text-sm text-muted-foreground">League teams</p>
        <h1 class="text-3xl font-semibold tracking-tight">Fantasy Teams</h1>
      </div>

      <section class="space-y-4">
        <%= if @owned_teams != [] do %>
          <p class="text-sm text-muted-foreground">Your team is listed first.</p>
        <% end %>
        <div class="grid grid-cols-1 gap-4 xl:grid-cols-2">
          <%= for team <- @owned_teams ++ @other_teams do %>
            <.team_card fantasy_team={team} />
          <% end %>
        </div>
      </section>
    </div>
    """
  end
end
