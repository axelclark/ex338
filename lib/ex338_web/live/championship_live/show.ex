defmodule Ex338Web.ChampionshipLive.Show do
  @moduledoc false

  use Ex338Web, :live_view

  alias Ex338.Championships
  alias Ex338.Chats
  alias Ex338.Chats.Message
  alias Ex338.Events
  alias Ex338.FantasyLeagues
  alias Ex338.FantasyTeamAuthorizer
  alias Ex338.InSeasonDraftPicks
  alias Ex338.InSeasonDraftPicks.InSeasonDraftPick
  alias Ex338Web.ChampionshipLive.ChatComponent
  alias Ex338Web.Presence

  require Logger

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      InSeasonDraftPicks.subscribe()
      schedule_refresh()
    end

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _session, socket) do
    %{"fantasy_league_id" => fantasy_league_id, "championship_id" => championship_id} = params

    fantasy_league = FantasyLeagues.get(fantasy_league_id)

    championship =
      Championships.get_championship_by_league(championship_id, fantasy_league_id)

    socket =
      socket
      |> assign(:fantasy_league, fantasy_league)
      |> assign(:championship, championship)
      |> assign_chat()

    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp assign_chat(socket) do
    %{fantasy_league: fantasy_league, championship: championship} = socket.assigns

    with true <- championship.in_season_draft,
         %{chat: chat} <-
           FantasyLeagues.get_draft_by_league_and_championship(fantasy_league, championship) do
      if connected?(socket) && chat do
        Chats.subscribe(chat, socket.assigns.current_user)
      end

      current_user = socket.assigns.current_user

      if chat && current_user do
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
    else
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

  defp apply_action(socket, :in_season_draft_pick_edit, params) do
    with pick_id when not is_nil(pick_id) <- params["in_season_draft_pick_id"],
         %InSeasonDraftPick{} = in_season_draft_pick <-
           InSeasonDraftPicks.pick_with_assocs(pick_id),
         :ok <- authorize_pick(socket, in_season_draft_pick) do
      available_fantasy_players = InSeasonDraftPicks.available_players(in_season_draft_pick)

      socket
      |> assign(:in_season_draft_pick, in_season_draft_pick)
      |> assign(:available_fantasy_players, available_fantasy_players)
    else
      _nil_or_error ->
        %{fantasy_league: fantasy_league, championship: championship} = socket.assigns
        push_navigate(socket, to: show_path(fantasy_league, championship))
    end
  end

  defp apply_action(socket, :show, _params) do
    socket
  end

  defp show_path(fantasy_league, championship) do
    ~p"/fantasy_leagues/#{fantasy_league}/championships/#{championship}"
  end

  defp authorize_pick(socket, in_season_draft_pick) do
    FantasyTeamAuthorizer.authorize(
      :edit_in_season_draft_pick,
      socket.assigns.current_user,
      in_season_draft_pick
    )
  end

  @impl true

  def handle_event(
        "create_draft_picks",
        _params,
        %{assigns: %{current_user: %{admin: true}}} = socket
      ) do
    %{fantasy_league: fantasy_league, championship: championship} = socket.assigns

    case InSeasonDraftPicks.create_picks_for_league(fantasy_league.id, championship.id) do
      {:ok, new_picks} ->
        {:noreply,
         socket
         |> put_flash(:info, "#{inspect(Enum.count(new_picks))} picks successfully created.")
         |> push_patch(to: show_path(fantasy_league, championship))}

      {:error, _, changeset, _} ->
        {:noreply,
         socket
         |> put_flash(:error, "Error when creating draft picks: #{inspect(changeset.errors)}")
         |> push_patch(to: show_path(fantasy_league, championship))}
    end
  end

  def handle_event(
        "create_draft_chat",
        _params,
        %{assigns: %{current_user: %{admin: true}}} = socket
      ) do
    %{fantasy_league: fantasy_league, championship: championship} = socket.assigns

    case FantasyLeagues.create_draft_chat_for_championship(fantasy_league, championship) do
      {:ok, _chat_and_fantasy_league_draft} ->
        {:noreply,
         socket
         |> put_flash(:info, "Successfully created chat for in season draft")
         |> push_patch(to: show_path(fantasy_league, championship))}

      {:error, changeset} ->
        {:noreply,
         socket
         |> put_flash(
           :error,
           "Error when creating draft chat: #{inspect(changeset.errors)}"
         )
         |> push_patch(to: show_path(fantasy_league, championship))}
    end
  end

  def handle_event(event, _params, socket) do
    Logger.info(
      "Unhandled event: #{inspect(event)} for current user #{socket.assigns.current_user.id || "nil"}"
    )

    {:noreply, socket}
  end

  @impl true
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

    if in_season_draft_pick.fantasy_league_id == fantasy_league_id do
      championship =
        Championships.get_championship_by_league(
          socket.assigns.championship.id,
          socket.assigns.fantasy_league.id
        )

      # need the preloaded in season draft pick
      in_season_draft_pick =
        Enum.find(championship.in_season_draft_picks, &(&1.id == in_season_draft_pick.id))

      %{
        draft_pick_asset: %{fantasy_team: %{team_name: team_name}},
        drafted_player: %{player_name: player_name}
      } = in_season_draft_pick

      socket =
        socket
        |> put_flash(:info, "#{team_name} selected #{player_name}!")
        |> push_event("animate", %{id: "draft-pick-#{in_season_draft_pick.id}-player"})
        |> assign(:championship, championship)

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

  # Implementations

  defp schedule_refresh do
    one_second = 1000
    Process.send_after(self(), :refresh, one_second)
  end

  def display_autodraft_setting(:single), do: "⚠️ Make Pick & Pause"
  def display_autodraft_setting(:on), do: "✅ On"
  def display_autodraft_setting(:off), do: "❌ Off"

  @impl true
  def render(assigns) do
    ~H"""
    <div class="overflow-hidden bg-white shadow sm:rounded-lg">
      <div class="px-4 py-5 border-b border-gray-200 sm:px-6">
        <div class="flex flex-wrap items-center justify-between -mt-2 -ml-4 sm:flex-no-wrap">
          <div class="mt-2 ml-4">
            <h3 class="text-lg font-medium text-gray-900 leading-6">
              <div class="flex items-center">
                <div class="ml-1">
                  <%= @championship.title %>
                </div>
                <%= if transaction_deadline_icon(@championship) != "" do %>
                  <div class="w-4 h-4 ml-1">
                    <%= transaction_deadline_icon(@championship) %>
                  </div>
                <% end %>
              </div>
            </h3>
          </div>
          <div class="flex items-center">
            <%= if show_create_slots(@current_user, @championship) do %>
              <div class="flex-shrink-0 mt-2 ml-4">
                <.link
                  href={
                    ~p"/fantasy_leagues/#{@fantasy_league.id}/championship_slot_admin?#{%{championship_id: @championship.id}}"
                  }
                  class="bg-transparent hover:bg-indigo-500 text-indigo-600 text-sm font-medium hover:text-white py-2 px-4 border border-indigo-600 hover:border-transparent rounded"
                  method="post"
                  data-confirm="Please confirm to create roster slots"
                >
                  Create Roster Slots
                </.link>
              </div>
            <% end %>

            <%= if show_create_picks(@current_user, @championship) do %>
              <div class="flex-shrink-0 mt-2 ml-4">
                <button
                  id="create-draft-picks-button"
                  type="button"
                  phx-click="create_draft_picks"
                  class="bg-transparent hover:bg-indigo-500 text-indigo-600 text-sm font-medium hover:text-white py-2 px-4 border border-indigo-600 hover:border-transparent rounded"
                >
                  Create Draft Picks
                </button>
              </div>
            <% end %>
            <%= if show_create_chat(@current_user, @championship, @chat) do %>
              <div class="flex-shrink-0 mt-2 ml-4">
                <button
                  id="create-chat-button"
                  type="button"
                  phx-click="create_draft_chat"
                  class="bg-transparent hover:bg-indigo-500 text-indigo-600 text-sm font-medium hover:text-white py-2 px-4 border border-indigo-600 hover:border-transparent rounded"
                >
                  Create Chat
                </button>
              </div>
            <% end %>
          </div>
        </div>
      </div>
      <div class="px-4 py-5 sm:p-0">
        <dl>
          <div class="sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6 sm:py-5">
            <dt class="text-sm font-medium text-gray-500 leading-5">
              SportsLeague
            </dt>
            <dd class="mt-1 text-sm text-gray-900 leading-5 sm:mt-0 sm:col-span-2">
              <%= @championship.sports_league.league_name %>
            </dd>
          </div>
          <div class="mt-8 sm:mt-0 sm:grid sm:grid-cols-3 sm:gap-4 sm:border-t sm:border-gray-200 sm:px-6 sm:py-5">
            <dt class="text-sm font-medium text-gray-500 leading-5">
              Waiver Deadline
            </dt>
            <dd class="mt-1 text-sm text-gray-900 leading-5 sm:mt-0 sm:col-span-2">
              <%= short_datetime_pst(@championship.waiver_deadline_at) %>
            </dd>
          </div>
          <div class="mt-8 sm:mt-0 sm:grid sm:grid-cols-3 sm:gap-4 sm:border-t sm:border-gray-200 sm:px-6 sm:py-5">
            <dt class="text-sm font-medium text-gray-500 leading-5">
              Trade Deadline
            </dt>
            <dd class="mt-1 text-sm text-gray-900 leading-5 sm:mt-0 sm:col-span-2">
              <%= short_datetime_pst(@championship.trade_deadline_at) %>
            </dd>
          </div>
          <%= if @championship.draft_starts_at do %>
            <div class="mt-8 sm:mt-0 sm:grid sm:grid-cols-3 sm:gap-4 sm:border-t sm:border-gray-200 sm:px-6 sm:py-5">
              <dt class="text-sm font-medium text-gray-500 leading-5">
                Draft Starts At
              </dt>
              <dd class="mt-1 text-sm text-gray-900 leading-5 sm:mt-0 sm:col-span-2">
                <%= short_datetime_pst(@championship.draft_starts_at) %>
              </dd>
            </div>
            <div class="mt-8 sm:mt-0 sm:grid sm:grid-cols-3 sm:gap-4 sm:border-t sm:border-gray-200 sm:px-6 sm:py-5">
              <dt class="text-sm font-medium text-gray-500 leading-5">
                Time Limit For Each Pick
              </dt>
              <dd class="mt-1 text-sm text-gray-900 leading-5 sm:mt-0 sm:col-span-2">
                <%= @championship.max_draft_mins %> Minutes
              </dd>
            </div>
          <% end %>
          <div class="mt-8 sm:mt-0 sm:grid sm:grid-cols-3 sm:gap-4 sm:border-t sm:border-gray-200 sm:px-6 sm:py-5">
            <dt class="text-sm font-medium text-gray-500 leading-5">
              Championship Date
            </dt>
            <dd class="mt-1 text-sm text-gray-900 leading-5 sm:mt-0 sm:col-span-2">
              <%= short_date_pst(@championship.championship_at) %>
            </dd>
          </div>
          <div class="mt-8 sm:mt-0 sm:grid sm:grid-cols-3 sm:gap-4 sm:border-t sm:border-gray-200 sm:px-6 sm:py-5">
            <dt class="text-sm font-medium text-gray-500 leading-5">
              Timezones
            </dt>
            <dd class="mt-1 text-sm text-gray-900 leading-5 sm:mt-0 sm:col-span-2">
              All dates and times are in Pacific Standard Time (PST)/Pacific Daylight Time (PDT).
            </dd>
          </div>
        </dl>
      </div>
    </div>

    <div class="grid grid-cols-1 gap-4 lg:grid-cols-2">
      <%= if @championship.events == [] do %>
        <div class="col-span-2">
          <.section_header>
            <%= @championship.title %> Results
          </.section_header>

          <.results_table championship={@championship} />
        </div>
      <% else %>
        <div class="col-span-1">
          <.section_header>
            <%= @championship.title %> Results
          </.section_header>

          <.final_results_table championship={@championship} />
        </div>

        <div class="col-span-1">
          <.section_header>
            <%= @championship.title %> Overall Standings
          </.section_header>

          <.slots_standings championship={@championship} />
        </div>
      <% end %>

      <%= if @championship.championship_slots !== [] do %>
        <div class="col-span-1">
          <.section_header>
            <%= @championship.title %> Roster Slots
          </.section_header>

          <.slots_table current_user={@current_user} championship={@championship} />
        </div>
      <% end %>

      <%= for event <- @championship.events do %>
        <div class="col-span-1">
          <.section_header>
            <%= event.title %> Results
          </.section_header>

          <.results_table championship={event} />
        </div>

        <%= if event.championship_slots !== [] do %>
          <div class="col-span-1">
            <.section_header>
              <%= event.title %> Roster Slots
            </.section_header>

            <.slots_table current_user={@current_user} championship={event} />
          </div>
        <% end %>
      <% end %>

      <%= if @championship.in_season_draft do %>
        <div class="col-span-2 xl:col-span-1">
          <.section_header>
            <%= @championship.title %> Draft
          </.section_header>
          <.inseason_draft_table
            championship={@championship}
            socket={@socket}
            current_user={@current_user}
            fantasy_league={@fantasy_league}
          />
        </div>
      <% end %>
      <%= if @current_user && @chat do %>
        <div class="col-span-2 xl:col-span-1">
          <.section_header>
            Draft Chat
          </.section_header>
          <.chat_list
            championship={@championship}
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
    <.modal
      :if={@live_action == :in_season_draft_pick_edit}
      id="in-season-draft-pick-modal"
      show
      on_cancel={JS.patch(show_path(@fantasy_league, @championship))}
    >
      <.live_component
        module={Ex338Web.ChampionshipLive.InSeasonDraftPickFormComponent}
        id={@in_season_draft_pick.id}
        fantasy_league={@fantasy_league}
        in_season_draft_pick={@in_season_draft_pick}
        available_fantasy_players={@available_fantasy_players}
        patch={show_path(@fantasy_league, @championship)}
      />
    </.modal>
    """
  end

  defp results_table(assigns) do
    ~H"""
    <.legacy_table class="md:!max-w-3xl">
      <thead>
        <tr>
          <.legacy_th>
            Rank
          </.legacy_th>
          <.legacy_th>
            Points
          </.legacy_th>
          <.legacy_th>
            Fantasy Player
          </.legacy_th>
          <.legacy_th>
            Owner
          </.legacy_th>
        </tr>
      </thead>
      <tbody class="bg-white">
        <%= for result <- @championship.championship_results do %>
          <tr>
            <.legacy_td>
              <%= result.rank %>
            </.legacy_td>
            <.legacy_td>
              <%= result.points %>
            </.legacy_td>
            <.legacy_td>
              <%= result.fantasy_player.player_name %>
            </.legacy_td>
            <.legacy_td>
              <%= get_team_name(result) %>
            </.legacy_td>
          </tr>
        <% end %>
      </tbody>
    </.legacy_table>
    """
  end

  defp final_results_table(assigns) do
    ~H"""
    <.legacy_table class="md:!max-w-2xl">
      <thead>
        <tr>
          <.legacy_th>
            Rank
          </.legacy_th>
          <.legacy_th>
            Points
          </.legacy_th>
          <.legacy_th>
            Fantasy Team
          </.legacy_th>
        </tr>
      </thead>
      <tbody class="bg-white">
        <%= for result <- @championship.champ_with_events_results do %>
          <tr>
            <.legacy_td>
              <%= result.rank %>
            </.legacy_td>
            <.legacy_td>
              <%= result.points %>
            </.legacy_td>
            <.legacy_td>
              <%= result.fantasy_team.team_name %>
            </.legacy_td>
          </tr>
        <% end %>
      </tbody>
    </.legacy_table>
    """
  end

  defp slots_standings(assigns) do
    ~H"""
    <.legacy_table class="md:!max-w-2xl">
      <thead>
        <tr>
          <.legacy_th>
            Rank
          </.legacy_th>
          <.legacy_th>
            Fantasy Team
          </.legacy_th>
          <.legacy_th>
            Slot
          </.legacy_th>
          <.legacy_th>
            Points
          </.legacy_th>
        </tr>
      </thead>
      <tbody class="bg-white">
        <%= for slot <- @championship.slot_standings do %>
          <tr>
            <.legacy_td>
              <%= slot.rank %>
            </.legacy_td>
            <.legacy_td>
              <%= slot.team_name %>
            </.legacy_td>
            <.legacy_td>
              <%= slot.slot %>
            </.legacy_td>
            <.legacy_td>
              <%= slot.points %>
            </.legacy_td>
          </tr>
        <% end %>
      </tbody>
    </.legacy_table>
    """
  end

  defp slots_table(assigns) do
    ~H"""
    <.legacy_table class="md:!max-w-2xl">
      <thead>
        <tr>
          <.legacy_th>
            Fantasy Team
          </.legacy_th>
          <.legacy_th>
            Slot
          </.legacy_th>
          <.legacy_th>
            Fantasy Player
          </.legacy_th>
          <%= if admin?(@current_user) do %>
            <.legacy_th>
              Action
            </.legacy_th>
          <% end %>
        </tr>
      </thead>
      <tbody class="bg-white">
        <%= for slot <- @championship.championship_slots do %>
          <tr>
            <.legacy_td>
              <%= slot.roster_position.fantasy_team.team_name %>
            </.legacy_td>
            <.legacy_td>
              <%= slot.slot %>
            </.legacy_td>
            <.legacy_td>
              <%= slot.roster_position.fantasy_player.player_name %>
            </.legacy_td>
            <%= if admin?(@current_user) do %>
              <.legacy_td>
                <.link
                  href={~p"/admin/#{"championships"}/#{"championship_slot"}/#{slot.id}"}
                  class="font-medium text-indigo-600 hover:text-indigo-500 transition duration-150 ease-in-out"
                >
                  Edit
                </.link>
              </.legacy_td>
            <% end %>
          </tr>
        <% end %>
      </tbody>
    </.legacy_table>
    """
  end

  def inseason_draft_table(assigns) do
    ~H"""
    <.legacy_table class="md:!max-w-full">
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
            <.legacy_td
              id={"draft-pick-#{pick.id}-player"}
              data-animate={animate_in("#draft-pick-#{pick.id}-player")}
            >
              <%= if pick.drafted_player do %>
                <%= pick.drafted_player.player_name %>
              <% else %>
                <%= if pick.available_to_pick? && (owner?(@current_user, pick) || admin?(@current_user)) do %>
                  <.link
                    patch={
                      ~p"/fantasy_leagues/#{@fantasy_league}/championships/#{@championship}/in_season_draft_picks/#{pick}/edit"
                    }
                    class="text-indigo-700"
                  >
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

  attr :chat, :map, required: true
  attr :championship, :map, required: true
  attr :current_user, :map, required: true
  attr :fantasy_league, :map, required: true
  attr :message, :map, required: true
  attr :messages, :list, required: true
  attr :users, :list, required: true

  def chat_list(assigns) do
    ~H"""
    <div class="overflow-hidden bg-white shadow sm:rounded-lg">
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
          patch={~p"/fantasy_leagues/#{@fantasy_league.id}/championships/#{@championship.id}"}
        />
        <div class="mt-4 px-4 sm:px-6 ">
          <h3>Online Users</h3>
          <%= for user <- @users do %>
            <p id={"online-user-#{user.user_id}"}>
              <span class="inline-block h-2 w-2 flex-shrink-0 rounded-full bg-green-400">
                <span class="sr-only">Online</span>
              </span>
              <span class="ml-1 text-xs leading-5 font-medium text-gray-900">
                <%= user.name %>
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
        Welcome to the <%= @chat.room_name %> draft chat!
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
        <%= @message.content %>
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
          <%= user_name(@message.user, @fantasy_league) %>
        </p>
        <div class="flex-none py-0.5 whitespace-nowrap text-xs leading-5 text-gray-500">
          <.local_time at={@message.inserted_at} id={@message.id} />
        </div>
      </div>
      <p class="pl-10 text-xs leading-6 text-gray-500">
        <%= @message.content %>
      </p>
    </li>
    """
  end

  attr :name, :string, required: true
  attr :class, :string, default: nil

  defp user_icon(assigns) do
    ~H"""
    <div class={[
      "h-6 w-6 flex flex-shrink-0 items-center justify-center bg-gray-600 rounded-full text-xs font-medium text-white",
      @class
    ]}>
      <%= get_initials(@name) %>
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

  defp get_team_name(%{fantasy_player: %{roster_positions: [position]}}) do
    position.fantasy_team.team_name
  end

  defp get_team_name(_) do
    "-"
  end

  defp show_create_chat(%{admin: true}, championship, nil) do
    championship.in_season_draft and
      DateTime.before?(DateTime.utc_now(), championship.championship_at)
  end

  defp show_create_chat(_user, _championship, _chat) do
    false
  end

  defp show_create_slots(%{admin: true}, %{category: "event", championship_slots: []}) do
    true
  end

  defp show_create_slots(_user, _championship) do
    false
  end

  defp show_create_picks(%{admin: true}, %{in_season_draft: true, in_season_draft_picks: []}) do
    true
  end

  defp show_create_picks(_user, _championship) do
    false
  end

  defp display_drafted_at_or_pick_due_at(%{available_to_pick?: false, drafted_player_id: nil}) do
    "---"
  end

  defp display_drafted_at_or_pick_due_at(
         %{available_to_pick?: true, drafted_player_id: nil} = assigns
       ) do
    if assigns.over_time? do
      ~H"""
      <div class="text-red-600">
        <%= short_time_secs_pst(assigns.pick_due_at) %>*
      </div>
      """
    else
      ~H"""
      <div class="text-gray-800">
        <%= short_time_secs_pst(assigns.pick_due_at) %>*
      </div>
      """
    end
  end

  defp display_drafted_at_or_pick_due_at(%{drafted_at: nil}) do
    "---"
  end

  defp display_drafted_at_or_pick_due_at(pick) do
    short_time_pst(pick.drafted_at)
  end

  attr :at, :any, required: true
  attr :id, :any, required: true

  def local_time(assigns) do
    ~H"""
    <time phx-hook="LocalTimeHook" id={"time-#{@id}"} class="invisible"><%= @at %></time>
    """
  end

  def animate_in(element_id) do
    JS.add_class("animate-in zoom-in duration-500", to: element_id)
  end
end
