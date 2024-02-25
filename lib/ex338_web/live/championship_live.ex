defmodule Ex338Web.ChampionshipLive do
  @moduledoc false
  use Ex338Web, :live_view

  import Ex338Web.ChampionshipHTML, only: [display_drafted_at_or_pick_due_at: 1]
  import Ex338Web.CoreComponents

  alias Ex338.Accounts
  alias Ex338.Championships
  alias Ex338.FantasyLeagues
  alias Ex338.InSeasonDraftPicks

  def mount(_params, session, socket) do
    if connected?(socket) do
      InSeasonDraftPicks.subscribe()
      schedule_refresh()
    end

    %{
      "championship_id" => championship_id,
      "fantasy_league_id" => fantasy_league_id,
      "current_user_id" => current_user_id
    } = session

    socket =
      socket
      |> assign_new(:championship, fn ->
        Championships.get_championship_by_league(
          championship_id,
          fantasy_league_id
        )
      end)
      |> assign_new(:current_user, fn -> maybe_update_current_user(current_user_id) end)
      |> assign_new(:fantasy_league, fn -> FantasyLeagues.get(fantasy_league_id) end)

    # need to clear flash from controller so not displayed twice
    socket = clear_flash(socket)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.legacy_table class="md:max-w-2xl">
      <thead>
        <tr>
          <.legacy_th>
            Order
          </.legacy_th>
          <.legacy_th>
            Drafted / Due*
          </.legacy_th>
          <.legacy_th>
            Fantasy Team
          </.legacy_th>
          <.legacy_th>
            Fantasy Player
          </.legacy_th>
        </tr>
      </thead>
      <tbody class="bg-white">
        <%= for pick <- @championship.in_season_draft_picks do %>
          <tr>
            <.legacy_td>
              <%= pick.position %>
            </.legacy_td>
            <.legacy_td>
              <%= display_drafted_at_or_pick_due_at(pick) %>
            </.legacy_td>
            <.legacy_td style="word-break: break-word;">
              <%= if pick.draft_pick_asset.fantasy_team do %>
                <%= fantasy_team_link(@socket, pick.draft_pick_asset.fantasy_team) %>
              <% end %>
              <%= if admin?(@current_user) do %>
                <%= " - " <>
                  display_autodraft_setting(pick.draft_pick_asset.fantasy_team.autodraft_setting) %>
              <% end %>
            </.legacy_td>
            <.legacy_td>
              <%= if pick.drafted_player do %>
                <%= pick.drafted_player.player_name %>
              <% else %>
                <%= if pick.available_to_pick? && (owner?(@current_user, pick) || admin?(@current_user)) do %>
                  <.link href={~p"/in_season_draft_picks/#{pick}/edit"} class="text-indigo-700">
                    Submit Pick
                  </.link>
                <% end %>
              <% end %>
            </.legacy_td>
          </tr>
        <% end %>
      </tbody>
    </.legacy_table>
    """
  end

  def handle_info(:refresh, socket) do
    championship = Championships.update_next_in_season_pick(socket.assigns.championship)

    socket =
      assign(socket, :championship, championship)

    schedule_refresh()

    {:noreply, socket}
  end

  def handle_info(
        {"in_season_draft_pick", [:in_season_draft_pick | _], in_season_draft_pick},
        socket
      ) do
    fantasy_league_id = socket.assigns.fantasy_league.id

    championship =
      Championships.get_championship_by_league(
        socket.assigns.championship.id,
        socket.assigns.fantasy_league.id
      )

    socket =
      socket
      |> maybe_put_flash(in_season_draft_pick, fantasy_league_id)
      |> assign(:championship, championship)

    {:noreply, socket}
  end

  # Implementations

  defp schedule_refresh do
    one_second = 1000
    Process.send_after(self(), :refresh, one_second)
  end

  defp maybe_update_current_user(nil), do: nil

  defp maybe_update_current_user(current_user_id) do
    Accounts.get_user!(current_user_id)
  end

  ## handle_info in_season_draft_pick

  defp maybe_put_flash(socket, %{fantasy_league_id: league_id}, league_id) do
    put_flash(
      socket,
      :info,
      "New pick!"
    )
  end

  defp maybe_put_flash(socket, _, _), do: socket

  def display_autodraft_setting(:single), do: "⚠️ Make Pick & Pause"
  def display_autodraft_setting(:on), do: "✅ On"
  def display_autodraft_setting(:off), do: "❌ Off"
end
