defmodule Ex338Web.DraftPickLive.Index do
  @moduledoc false
  use Ex338Web, :live_view

  alias Ex338.Chats
  alias Ex338.Chats.Chat
  alias Ex338.Chats.Message
  alias Ex338.DraftPicks
  alias Ex338.Events
  alias Ex338.FantasyLeagues
  alias Ex338.FantasyTeams
  alias Ex338Web.ChampionshipLive.ChatComponent
  alias Ex338Web.Presence

  require Logger

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      DraftPicks.subscribe()
      schedule_refresh()
    end

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"fantasy_league_id" => fantasy_league_id}, _, socket) do
    %{draft_picks: picks, fantasy_teams: teams} =
      DraftPicks.get_picks_for_league(fantasy_league_id)

    filter_params = %{sports_league_id: "", fantasy_team_id: ""}

    filtered_draft_picks = filter_draft_picks(picks, filter_params)

    socket =
      socket
      |> assign(:fantasy_teams, teams)
      |> assign(:draft_picks, picks)
      |> assign(filter_params)
      |> assign(:filtered_draft_picks, filtered_draft_picks)
      |> assign(:fantasy_league, FantasyLeagues.get(fantasy_league_id))
      |> assign(:sports_league_options, sports_league_options(picks))
      |> assign(:fantasy_team_options, fantasy_team_options(picks))
      |> assign_chat()

    {:noreply, socket}
  end

  defp assign_chat(socket) do
    %{fantasy_league: fantasy_league} = socket.assigns

    case FantasyLeagues.get_draft_by_league(fantasy_league) do
      %{chat: %Chat{} = chat} ->
        if connected?(socket) do
          Chats.subscribe(chat, socket.assigns.current_user)
        end

        current_user = socket.assigns.current_user

        if current_user do
          Presence.track(
            self(),
            Chats.topic(chat),
            current_user.id,
            default_user_presence_payload(current_user)
          )
        end

        socket
        |> assign(:chat, chat)
        |> assign(:message, %Message{})
        |> stream(:messages, chat.messages)
        |> assign(:users, Presence.list_presences(Chats.topic(chat)))

      _ ->
        socket
        |> assign(:chat, nil)
        |> assign(:message, nil)
        |> assign(:users, [])
        |> stream(:messages, [])
    end
  end

  defp default_user_presence_payload(user) do
    %{
      name: user.name,
      user_id: user.id
    }
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex items-center justify-between">
      <.page_header>
        Draft Picks for Division {@fantasy_league.division}
      </.page_header>
      <%= if admin?(@current_user) && is_nil(@chat) do %>
        <div class="shrink-0 mt-2 ml-4">
          <button
            id="create-chat-button"
            type="button"
            phx-click="create_draft_chat"
            class="bg-white hover:bg-indigo-500 text-indigo-600 text-sm font-medium hover:text-white py-2 px-4 border border-indigo-600 hover:border-transparent rounded-sm"
          >
            Create Chat
          </button>
        </div>
      <% end %>
    </div>

    <h3 class="py-2 pl-4 text-base text-gray-700 sm:pl-6">
      Latest Picks
    </h3>
    <.current_table current_user={@current_user} draft_picks={current_picks(@draft_picks, 10)} />

    <div class="grid grid-cols-1 gap-4 lg:grid-cols-2">
      <div class="col-span-1">
        <.section_header>
          Time On the Clock
        </.section_header>

        <.team_summary_table current_user={@current_user} fantasy_teams={@fantasy_teams} />

        <%= if @fantasy_league.max_draft_hours > 0 do %>
          <p class="pl-4 mt-1 text-sm font-medium text-gray-700 leading-5 sm:mt-2 sm:pl-6">
            The commish has set a max total time limit of <strong><%= @fantasy_league.max_draft_hours %> hours</strong>.  Once a team has exceeded the total hours, it can be skipped in the draft order. Teams over the total draft time limit can avoid getting skipped by using the draft queue.
          </p>
        <% end %>
      </div>
      <%= if @current_user && @chat do %>
        <div class="col-span-1">
          <.section_header>
            Draft Chat
          </.section_header>
          <.chat_list
            chat={@chat}
            current_user={@current_user}
            fantasy_league={@fantasy_league}
            messages={@streams.messages}
            message={@message}
            users={@users}
          />
        </div>
      <% end %>
    </div>

    <.section_header>
      Draft Picks
    </.section_header>

    <.form :let={f} for={%{}} as={:filter} phx-change="filter">
      <div class="mt-1 mb-4 grid grid-cols-1 gap-y-2 gap-x-8 sm:grid-cols-6">
        <div class="sm:col-span-2">
          <label for="location" class="block ml-1 text-sm font-medium text-gray-700 sm:ml-0 leading-5">
            Filter by team
          </label>
          <.input
            field={f[:fantasy_team_id]}
            type="select"
            options={@fantasy_team_options}
            class="block w-full py-2 pl-3 pr-10 mt-1 text-base border-gray-300 form-select leading-6 focus:outline-hidden focus:shadow-outline-blue focus:border-blue-300 sm:text-sm sm:leading-5"
          />
        </div>

        <div class="sm:col-span-2">
          <label for="location" class="block ml-1 text-sm font-medium text-gray-700 sm:ml- leading-5">
            Filter by sport
          </label>
          <.input
            field={f[:sports_league_id]}
            type="select"
            options={@sports_league_options}
            class="block w-full py-2 pl-3 pr-10 mt-1 text-base border-gray-300 form-select leading-6 focus:outline-hidden focus:shadow-outline-blue focus:border-blue-300 sm:text-sm sm:leading-5"
          />
        </div>
      </div>
    </.form>

    <.draft_table current_user={@current_user} filtered_draft_picks={@filtered_draft_picks} />
    """
  end

  defp current_table(assigns) do
    ~H"""
    <.legacy_table class="lg:max-w-4xl">
      <thead>
        <tr>
          <.legacy_th class="hidden sm:table-cell">
            Overall Pick
          </.legacy_th>
          <.legacy_th>
            Draft Position
          </.legacy_th>
          <.legacy_th>
            Fantasy Team
          </.legacy_th>
          <.legacy_th>
            Fantasy Player
          </.legacy_th>
          <.legacy_th>
            Sports League
          </.legacy_th>
        </tr>
      </thead>
      <tbody class="bg-white">
        <%= for draft_pick <- @draft_picks do %>
          <tr
            id={"current-draft-pick-#{draft_pick.id}"}
            data-animate={animate_in("#current-draft-pick-#{draft_pick.id}")}
          >
            <.legacy_td class="hidden sm:table-cell">
              {draft_pick.pick_number}
            </.legacy_td>
            <.legacy_td>
              {draft_pick.draft_position}
            </.legacy_td>
            <.legacy_td style="word-break: break-word;">
              <%= if draft_pick.fantasy_team do %>
                <.fantasy_team_name_link fantasy_team={draft_pick.fantasy_team} />
              <% end %>
            </.legacy_td>
            <.legacy_td>
              <%= if draft_pick.fantasy_player do %>
                {draft_pick.fantasy_player.player_name}
              <% else %>
                <%= if draft_pick.available_to_pick? && (owner?(@current_user, draft_pick) || admin?(@current_user)) do %>
                  <.link href={~p"/draft_picks/#{draft_pick}/edit"} class="text-indigo-700">
                    Submit Pick
                  </.link>
                <% end %>
              <% end %>
            </.legacy_td>
            <.legacy_td>
              <%= if draft_pick.fantasy_player do %>
                {draft_pick.fantasy_player.sports_league.abbrev}
              <% end %>
            </.legacy_td>
          </tr>
        <% end %>
      </tbody>
    </.legacy_table>
    """
  end

  defp team_summary_table(assigns) do
    ~H"""
    <.legacy_table class="lg:max-w-4xl">
      <thead>
        <tr>
          <.legacy_th>
            Fantasy Team
          </.legacy_th>
          <.legacy_th class="text-center">
            Number of Picks
          </.legacy_th>
          <.legacy_th class="text-right">
            Avg Mins On the Clock
          </.legacy_th>
          <.legacy_th class="text-right">
            Total Hours On the Clock
          </.legacy_th>
        </tr>
      </thead>
      <tbody class="bg-white">
        <%= for team <- @fantasy_teams do %>
          <tr>
            <.legacy_td style="word-break: break-word;">
              <.fantasy_team_name_link fantasy_team={team} />
              <%= if admin?(@current_user) do %>
                {" - " <> FantasyTeams.display_autodraft_setting(team)}
              <% end %>
            </.legacy_td>
            <.legacy_td class="text-center">
              {team.picks_selected}
            </.legacy_td>
            <.legacy_td class="text-right">
              {seconds_to_mins(team.avg_seconds_on_the_clock)}
            </.legacy_td>
            <.legacy_td class="text-right">
              {seconds_to_hours(team.total_seconds_on_the_clock)}
            </.legacy_td>
          </tr>
        <% end %>
      </tbody>
    </.legacy_table>
    """
  end

  defp draft_table(assigns) do
    ~H"""
    <.legacy_table class="lg:max-w-4xl table draft-picks-table">
      <thead>
        <tr>
          <.legacy_th class="hidden sm:table-cell">
            Overall Pick
          </.legacy_th>
          <.legacy_th>
            Draft Position
          </.legacy_th>
          <.legacy_th>
            Fantasy Team
          </.legacy_th>
          <.legacy_th>
            Fantasy Player
          </.legacy_th>
          <.legacy_th>
            Sports League
          </.legacy_th>
        </tr>
      </thead>
      <tbody class="bg-white">
        <%= for draft_pick <- @filtered_draft_picks do %>
          <tr
            id={"draft-pick-#{draft_pick.id}"}
            data-animate={animate_in("#draft-pick-#{draft_pick.id}")}
          >
            <.legacy_td class="hidden sm:table-cell">
              {draft_pick.pick_number}
            </.legacy_td>
            <.legacy_td>
              {draft_pick.draft_position}
            </.legacy_td>
            <.legacy_td style="word-break: break-word;">
              <%= if draft_pick.fantasy_team do %>
                <.fantasy_team_name_link fantasy_team={draft_pick.fantasy_team} />
              <% end %>
            </.legacy_td>
            <.legacy_td>
              <%= if draft_pick.fantasy_player do %>
                {draft_pick.fantasy_player.player_name}
              <% else %>
                <%= if draft_pick.available_to_pick? && (owner?(@current_user, draft_pick) || admin?(@current_user)) do %>
                  <.link href={~p"/draft_picks/#{draft_pick}/edit"} class="text-indigo-700">
                    Submit Pick
                  </.link>
                <% end %>
              <% end %>
            </.legacy_td>
            <.legacy_td>
              <%= if draft_pick.fantasy_player do %>
                {draft_pick.fantasy_player.sports_league.abbrev}
              <% end %>
            </.legacy_td>
          </tr>
        <% end %>
      </tbody>
    </.legacy_table>
    """
  end

  attr :chat, :map, required: true
  attr :current_user, :map, required: true
  attr :fantasy_league, :map, required: true
  attr :message, :map, required: true
  attr :messages, :list, required: true
  attr :users, :list, required: true

  def chat_list(assigns) do
    ~H"""
    <div class="overflow-hidden bg-white shadow-sm sm:rounded-lg">
      <div class="py-5 border-b border-gray-200">
        <.welcome_comment chat={@chat} />
        <ul
          id="messages"
          phx-update="stream"
          role="list"
          phx-hook="ChatScrollToBottom"
          class="flex flex-col max-h-[400px] overflow-y-auto overflow-x-hidden"
        >
          <.comment
            :for={{id, message} <- @messages}
            id={id}
            message={message}
            fantasy_league={@fantasy_league}
          />
        </ul>

        <.live_component
          module={ChatComponent}
          id="chat"
          chat={@chat}
          message={@message}
          current_user={@current_user}
          patch={~p"/fantasy_leagues/#{@fantasy_league.id}/draft_picks"}
        />
        <div class="mt-4 px-4 sm:px-6 ">
          <h3>Online Users</h3>
          <%= for user <- @users do %>
            <p id={"online-user-#{user.user_id}"}>
              <span class="inline-block h-2 w-2 shrink-0 rounded-full bg-green-400">
                <span class="sr-only">Online</span>
              </span>
              <span class="ml-1 text-xs leading-5 font-medium text-gray-900">
                {user.name}
              </span>
            </p>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  attr :chat, :map, required: true

  defp welcome_comment(assigns) do
    ~H"""
    <li id="welcome-comment" class="flex gap-x-4 px-4 sm:px-6 pb-3">
      <div class="flex h-6 w-6 flex-none items-center justify-center">
        <.icon name="hero-chevron-right" class="h-6 w-6 text-indigo-600" />
      </div>
      <p class="flex-auto py-0.5 text-xs leading-5 text-gray-500">
        Welcome to the {@chat.room_name} draft chat!
      </p>
    </li>
    """
  end

  attr :id, :string, required: true
  attr :message, :map, required: true
  attr :fantasy_league, :map, required: true

  defp comment(%{message: %{user: nil}} = assigns) do
    ~H"""
    <li id={@id} class="flex gap-x-4 hover:bg-gray-50 px-4 sm:px-6 py-2">
      <div class="flex h-6 w-6 flex-none items-center justify-center">
        <.icon name="hero-check-circle" class="h-6 w-6 text-indigo-600" />
      </div>
      <p class="flex-auto py-0.5 text-xs leading-5 text-gray-500">
        {@message.content}
      </p>
      <div class="flex-none py-0.5 text-xs leading-5 text-gray-500">
        <.local_time at={@message.inserted_at} id={@message.id} />
      </div>
    </li>
    """
  end

  defp comment(assigns) do
    ~H"""
    <li id={@id} class="hover:bg-gray-50 px-4 sm:px-6 py-2">
      <div class="flex gap-x-4">
        <.user_icon name={@message.user.name} />
        <p class="flex-auto text-xs leading-5 font-medium text-gray-900 truncate">
          {user_name(@message.user, @fantasy_league)}
        </p>
        <div class="flex-none py-0.5 whitespace-nowrap text-xs leading-5 text-gray-500">
          <.local_time at={@message.inserted_at} id={@message.id} />
        </div>
      </div>
      <p class="pl-10 text-xs leading-6 text-gray-500">
        {@message.content}
      </p>
    </li>
    """
  end

  attr :name, :string, required: true
  attr :class, :string, default: nil

  defp user_icon(assigns) do
    ~H"""
    <div class={[
      "h-6 w-6 flex shrink-0 items-center justify-center bg-gray-600 rounded-full text-xs font-medium text-white",
      @class
    ]}>
      {get_initials(@name)}
    </div>
    """
  end

  defp user_name(user, fantasy_league) do
    with owner when not is_nil(owner) <- get_owner_in_league(user, fantasy_league),
         false <- owner.fantasy_team.team_name == user.name do
      "#{user.name} - #{owner.fantasy_team.team_name}"
    else
      _ -> user.name
    end
  end

  defp get_owner_in_league(user, fantasy_league) do
    Enum.find(user.owners, fn owner ->
      owner.fantasy_team.fantasy_league_id == fantasy_league.id
    end)
  end

  defp get_initials(name) do
    name
    |> String.split(" ")
    |> Enum.take(2)
    |> Enum.map_join("", &String.at(&1, 0))
  end

  attr :at, :any, required: true
  attr :id, :any, required: true

  defp local_time(assigns) do
    ~H"""
    <time phx-hook="LocalTimeHook" id={"time-#{@id}"} class="invisible">{@at}</time>
    """
  end

  @impl true
  def handle_info(:refresh, socket) do
    new_data = DraftPicks.get_picks_for_league(socket.assigns.fantasy_league.id)

    filtered_draft_picks = filter_draft_picks(new_data.draft_picks, socket.assigns)

    socket =
      socket
      |> assign(new_data)
      |> assign(filtered_draft_picks: filtered_draft_picks)

    schedule_refresh()

    {:noreply, socket}
  end

  def handle_info({"draft_pick", [:draft_pick | _], draft_pick}, socket) do
    fantasy_league_id = socket.assigns.fantasy_league.id

    if draft_pick.fantasy_league_id == fantasy_league_id do
      new_data = DraftPicks.get_picks_for_league(fantasy_league_id)
      filtered_draft_picks = filter_draft_picks(new_data.draft_picks, socket.assigns)

      socket =
        socket
        |> assign(new_data)
        |> assign(filtered_draft_picks: filtered_draft_picks)
        |> push_event("animate", %{id: "draft-pick-#{draft_pick.id}"})
        |> push_event("animate", %{id: "current-draft-pick-#{draft_pick.id}"})
        |> put_flash(
          :info,
          "#{draft_pick.fantasy_team.team_name} selected #{draft_pick.fantasy_player.player_name}!"
        )

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_info({Ex338.Chats, %Events.MessageCreated{message: message}}, socket) do
    {:noreply, stream_insert(socket, :messages, message)}
  end

  def handle_info(
        %{event: "presence_diff", payload: _payload},
        %{assigns: %{chat: chat}} = socket
      ) do
    users =
      Presence.list_presences(Chats.topic(chat))

    {:noreply, assign(socket, users: users)}
  end

  def handle_info(message, socket) do
    Logger.info("Unhandled message: #{inspect(message)}")
    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "filter",
        %{"filter" => %{"sports_league_id" => sport_id, "fantasy_team_id" => team_id}},
        socket
      ) do
    draft_picks = socket.assigns.draft_picks
    filter_params = %{sports_league_id: sport_id, fantasy_team_id: team_id}

    filtered_draft_picks = filter_draft_picks(draft_picks, filter_params)

    socket =
      socket
      |> assign(filtered_draft_picks: filtered_draft_picks)
      |> assign(filter_params)

    {:noreply, socket}
  end

  def handle_event(
        "create_draft_chat",
        _params,
        %{assigns: %{current_user: %{admin: true}}} = socket
      ) do
    %{fantasy_league: fantasy_league} = socket.assigns

    case FantasyLeagues.create_draft_chat_for_league(fantasy_league) do
      {:ok, _chat_and_fantasy_league_draft} ->
        {:noreply,
         socket
         |> put_flash(:info, "Successfully created chat for draft")
         |> push_patch(to: ~p"/fantasy_leagues/#{socket.assigns.fantasy_league.id}/draft_picks")}

      {:error, changeset} ->
        {:noreply,
         socket
         |> put_flash(
           :error,
           "Error when creating draft chat: #{inspect(changeset.errors)}"
         )
         |> push_patch(to: ~p"/fantasy_leagues/#{socket.assigns.fantasy_league.id}/draft_picks")}
    end
  end

  def handle_event(event, _params, socket) do
    Logger.info(
      "Unhandled event: #{inspect(event)} for current user #{socket.assigns.current_user.id || "nil"}"
    )

    {:noreply, socket}
  end

  ## Helpers

  def filter_draft_picks(draft_picks, %{
        fantasy_team_id: fantasy_team_id,
        sports_league_id: sports_league_id
      }) do
    draft_picks
    |> filter_draft_picks_by_sport(sports_league_id)
    |> filter_draft_picks_by_team(fantasy_team_id)
  end

  defp filter_draft_picks_by_sport(draft_picks, ""), do: draft_picks

  defp filter_draft_picks_by_sport(draft_picks, sports_league_id) do
    sports_league_id = String.to_integer(sports_league_id)

    Enum.filter(draft_picks, fn
      %{fantasy_player: %{sports_league: sports_league}} ->
        sports_league.id == sports_league_id

      _ ->
        false
    end)
  end

  defp filter_draft_picks_by_team(draft_picks, ""), do: draft_picks

  defp filter_draft_picks_by_team(draft_picks, fantasy_team_id) do
    fantasy_team_id = String.to_integer(fantasy_team_id)

    Enum.filter(draft_picks, fn
      %{fantasy_team: fantasy_team} ->
        fantasy_team.id == fantasy_team_id

      _ ->
        false
    end)
  end

  defp schedule_refresh, do: Process.send_after(self(), :refresh, 1000 * 60)

  defp current_picks(draft_picks, amount) when amount >= 0 do
    next_pick_index = Enum.find_index(draft_picks, &(&1.fantasy_player_id == nil))
    get_current_picks(draft_picks, next_pick_index, amount)
  end

  defp get_current_picks(draft_picks, nil, amount) do
    Enum.take(draft_picks, -div(amount, 2))
  end

  defp get_current_picks(draft_picks, index, amount) do
    start_index = index - div(amount, 2)

    start_index =
      if start_index < 0 do
        0
      else
        start_index
      end

    Enum.slice(draft_picks, start_index, amount)
  end

  defp seconds_to_hours(seconds) do
    Float.floor(seconds / 3600, 2)
  end

  defp seconds_to_mins(seconds) do
    Float.floor(seconds / 60, 2)
  end

  defp fantasy_team_options(draft_picks) do
    options =
      draft_picks
      |> Enum.reduce([], fn
        %{fantasy_team: fantasy_team}, options ->
          [{fantasy_team.team_name, fantasy_team.id}] ++ options

        _, options ->
          options
      end)
      |> Enum.uniq()
      |> Enum.sort_by(fn {team_name, _} -> team_name end)

    [{"All Teams", ""}] ++ options
  end

  defp sports_league_options(draft_picks) do
    options =
      draft_picks
      |> Enum.reduce([], fn
        %{fantasy_player: %{sports_league: sports_league}}, options ->
          [{sports_league.league_name, sports_league.id}] ++ options

        _, options ->
          options
      end)
      |> Enum.uniq()
      |> Enum.sort_by(fn {league_name, _} -> league_name end)

    [{"All Sports", ""}] ++ options
  end

  def animate_in(element_id) do
    JS.add_class("animate-in slide-in-from-right duration-500", to: element_id)
  end
end
