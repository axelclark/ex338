defmodule Ex338Web.FantasyTeamHTML do
  use Ex338Web, :html

  import Ex338Web.FantasyTeamComponents

  def index(assigns) do
    ~H"""
    <.page_header>
      Fantasy Teams
    </.page_header>

    <section>
      <div class="flex flex-row flex-wrap justify-between">
        <%= for team <- Enum.filter(@fantasy_teams, &owner?(@current_user, &1)) do %>
          <.team_card fantasy_team={team} />
        <% end %>
        <%= for team <- Enum.reject(@fantasy_teams, &owner?(@current_user, &1)) do %>
          <.team_card fantasy_team={team} />
        <% end %>
      </div>
    </section>
    """
  end
end
