defmodule Ex338Web.ChampionshipLive.ShowTest do
  use Ex338Web.ConnCase

  import Phoenix.LiveViewTest
  import Swoosh.TestAssertions

  alias Ex338.CalendarAssistant
  alias Ex338.DraftQueues.DraftQueue
  alias Ex338.InSeasonDraftPicks
  alias Ex338.InSeasonDraftPicks.InSeasonDraftPick

  describe "championship_live show/2" do
    test "shows overall championship and all results", %{conn: conn} do
      f_league = insert(:fantasy_league, year: 2017)
      team_with_champ = insert(:fantasy_team, fantasy_league: f_league)
      championship = insert(:championship, category: "overall")
      champ_player = insert(:fantasy_player)

      champ_position =
        insert(
          :roster_position,
          fantasy_team: team_with_champ,
          fantasy_player: champ_player
        )

      insert(
        :championship_slot,
        roster_position: champ_position,
        championship: championship
      )

      result =
        insert(
          :championship_result,
          championship: championship,
          fantasy_player: champ_player
        )

      team_with_slot = insert(:fantasy_team, fantasy_league: f_league)
      slot_player = insert(:fantasy_player)

      slot_pos =
        insert(
          :roster_position,
          fantasy_team: team_with_slot,
          fantasy_player: slot_player
        )

      insert(
        :championship_slot,
        roster_position: slot_pos,
        championship: championship
      )

      {:ok, _view, html} =
        live(conn, ~p"/fantasy_leagues/#{f_league.id}/championships/#{championship.id}")

      assert html =~ "Results"
      assert html =~ championship.title
      assert html =~ to_string(result.points)
      assert html =~ champ_player.player_name
      assert html =~ team_with_champ.team_name
      assert html =~ slot_player.player_name
      assert html =~ team_with_slot.team_name
    end

    test "shows championship event and all results", %{conn: conn} do
      f_league = insert(:fantasy_league, year: 2017)
      team_with_champ = insert(:fantasy_team, fantasy_league: f_league)
      championship = insert(:championship, category: "event")
      champ_player = insert(:fantasy_player)

      champ_position =
        insert(
          :roster_position,
          fantasy_team: team_with_champ,
          fantasy_player: champ_player
        )

      insert(
        :championship_slot,
        roster_position: champ_position,
        championship: championship
      )

      result =
        insert(
          :championship_result,
          championship: championship,
          fantasy_player: champ_player
        )

      team_with_slot = insert(:fantasy_team, fantasy_league: f_league)
      slot_player = insert(:fantasy_player)

      slot_pos =
        insert(
          :roster_position,
          fantasy_team: team_with_slot,
          fantasy_player: slot_player
        )

      insert(
        :championship_slot,
        roster_position: slot_pos,
        championship: championship
      )

      {:ok, _view, html} =
        live(conn, ~p"/fantasy_leagues/#{f_league.id}/championships/#{championship.id}")

      assert html =~ "Results"
      assert html =~ championship.title
      assert html =~ to_string(result.points)
      assert html =~ champ_player.player_name
      assert html =~ team_with_champ.team_name
      assert html =~ slot_player.player_name
      assert html =~ team_with_slot.team_name
    end

    test "shows overall championship with event and all results", %{conn: conn} do
      f_league = insert(:fantasy_league)
      championship = insert(:championship, category: "overall")
      event = insert(:championship, category: "event", overall: championship)
      event_b = insert(:championship, category: "event", overall: championship)

      team_with_champ = insert(:fantasy_team, fantasy_league: f_league)
      champ_player = insert(:fantasy_player)

      champ_position =
        insert(
          :roster_position,
          fantasy_team: team_with_champ,
          fantasy_player: champ_player
        )

      insert(:championship_slot, roster_position: champ_position, championship: event, slot: 1)

      result =
        insert(:championship_result, championship: event, fantasy_player: champ_player, points: 8)

      insert(:championship_slot, roster_position: champ_position, championship: event, slot: 1)
      insert(:championship_result, championship: event, fantasy_player: champ_player, points: 3)

      team_with_slot = insert(:fantasy_team, fantasy_league: f_league)
      slot_player = insert(:fantasy_player)

      slot_pos =
        insert(
          :roster_position,
          fantasy_team: team_with_slot,
          fantasy_player: slot_player
        )

      insert(:championship_slot, roster_position: slot_pos, championship: event, slot: 1)

      player_b = insert(:fantasy_player)

      pos_b =
        insert(
          :roster_position,
          fantasy_team: team_with_slot,
          fantasy_player: player_b
        )

      insert(:championship_slot, championship: event_b, roster_position: pos_b, slot: 1)
      insert(:championship_result, championship: event_b, points: 1, fantasy_player: player_b)

      insert(
        :champ_with_events_result,
        fantasy_team: team_with_champ,
        championship: championship,
        rank: 1,
        points: 8.0,
        winnings: 25.00
      )

      {:ok, _view, html} =
        live(conn, ~p"/fantasy_leagues/#{f_league.id}/championships/#{championship.id}")

      assert html =~ "Results"
      assert html =~ championship.title
      assert html =~ to_string(result.points)
      assert html =~ champ_player.player_name
      assert html =~ team_with_champ.team_name
      assert html =~ slot_player.player_name
      assert html =~ team_with_slot.team_name
      assert html =~ "Overall Standings"
      assert html =~ "#{championship.title} Results"
    end

    test "shows draft for overall championship and updates new pick", %{conn: conn} do
      league = insert(:fantasy_league)
      sport = insert(:sports_league)

      championship =
        insert(:championship, category: "overall", in_season_draft: true, sports_league: sport)

      team_a = insert(:fantasy_team, fantasy_league: league)

      pick1 =
        insert(:fantasy_player, sports_league: sport, draft_pick: true, player_name: "KD Pick #1")

      pick_asset1 = insert(:roster_position, fantasy_team: team_a, fantasy_player: pick1)

      horse =
        insert(:fantasy_player, sports_league: sport, draft_pick: false, player_name: "My Horse")

      insert(
        :in_season_draft_pick,
        draft_pick_asset: pick_asset1,
        championship: championship,
        position: 1,
        drafted_player: horse,
        drafted_at: CalendarAssistant.mins_from_now(-1)
      )

      team_b = insert(:fantasy_team, fantasy_league: league)

      pick2 =
        insert(:fantasy_player, sports_league: sport, draft_pick: true, player_name: "KD Pick #2")

      pick_asset2 = insert(:roster_position, fantasy_team: team_b, fantasy_player: pick2)

      horse2 =
        insert(:fantasy_player,
          sports_league: sport,
          draft_pick: false,
          player_name: "Another Horse"
        )

      in_season_draft_pick =
        insert(
          :in_season_draft_pick,
          draft_pick_asset: pick_asset2,
          championship: championship,
          fantasy_league: league,
          position: 2
        )

      {:ok, view, html} =
        live(conn, ~p"/fantasy_leagues/#{league.id}/championships/#{championship.id}")

      assert html =~ "Draft"
      assert html =~ team_a.team_name
      assert html =~ horse.player_name
      assert html =~ team_b.team_name
      refute html =~ horse2.player_name

      InSeasonDraftPicks.draft_player(in_season_draft_pick, %{
        "drafted_player_id" => horse2.id
      })

      assert render(view) =~ horse2.player_name

      assert has_element?(view, "div", "#{team_b.team_name} selected #{horse2.player_name}!")
    end
  end

  describe "championship_live show/2 with a logged in user" do
    setup :register_and_log_in_user

    test "shows draft for overall championship with chat", %{conn: conn, user: user} do
      league = insert(:fantasy_league)
      sport = insert(:sports_league)

      championship =
        insert(:championship, category: "overall", in_season_draft: true, sports_league: sport)

      team_a = insert(:fantasy_team, fantasy_league: league)
      insert(:owner, user: user, fantasy_team: team_a)

      pick1 =
        insert(:fantasy_player, sports_league: sport, draft_pick: true, player_name: "KD Pick #1")

      pick_asset1 = insert(:roster_position, fantasy_team: team_a, fantasy_player: pick1)

      horse =
        insert(:fantasy_player, sports_league: sport, draft_pick: false, player_name: "My Horse")

      insert(
        :in_season_draft_pick,
        draft_pick_asset: pick_asset1,
        championship: championship,
        position: 1,
        drafted_player: horse,
        drafted_at: CalendarAssistant.mins_from_now(-1)
      )

      chat = insert(:chat, room_name: "#{championship.title}:#{league.id}")
      insert(:message, chat: chat, user: user, content: "hello world!")

      insert(:fantasy_league_draft,
        fantasy_league: league,
        championship: championship,
        chat: chat
      )

      another_user = insert(:user)
      team_b = insert(:fantasy_team, fantasy_league: league)
      insert(:owner, user: another_user, fantasy_team: team_b)

      pick2 =
        insert(:fantasy_player, sports_league: sport, draft_pick: true, player_name: "KD Pick #2")

      pick_asset2 = insert(:roster_position, fantasy_team: team_b, fantasy_player: pick2)

      horse2 =
        insert(:fantasy_player,
          sports_league: sport,
          draft_pick: false,
          player_name: "Another Horse"
        )

      in_season_draft_pick =
        insert(
          :in_season_draft_pick,
          draft_pick_asset: pick_asset2,
          championship: championship,
          fantasy_league: league,
          position: 2
        )

      {:ok, view, _html} =
        live(conn, ~p"/fantasy_leagues/#{league.id}/championships/#{championship.id}")

      assert has_element?(view, "h3", "Draft")
      assert has_element?(view, "p", "hello world!")
      assert has_element?(view, "p#online-user-#{user.id}", user.name)

      long_comment = """
      In a quiet town nestled between rolling hills and dense forests, a small but spirited
      community thrives. Here, neighbors greet each other with warmth, and every street 
      echoes with the sound of laughter and lively conversations. It's a place where every 
      moment is cherished and every sunset promises a new beginning.
      """

      view
      |> form("#create-message-form", %{message: %{content: long_comment}})
      |> render_change() =~ "should be at most 280 characters"

      view
      |> form("#create-message-form", %{message: %{content: "My team is awesome!"}})
      |> render_submit()

      assert has_element?(view, "p", "My team is awesome!")

      {:ok, _chat} =
        Ex338.Chats.create_message(%{
          "content" => "Wow",
          "user_id" => another_user.id,
          "chat_id" => chat.id
        })

      render(view)

      assert has_element?(view, "p", "Wow")

      InSeasonDraftPicks.draft_player(in_season_draft_pick, %{
        "drafted_player_id" => horse2.id
      })

      assert render(view) =~ horse2.player_name

      draft_flash = "#{team_b.team_name} selected #{horse2.player_name}!"
      assert has_element?(view, "div", draft_flash)

      draft_chat_message =
        "#{team_b.team_name} drafted #{horse2.player_name} with pick ##{in_season_draft_pick.position}"

      assert has_element?(view, "p", draft_chat_message)
    end

    test "shows draft for overall championship with form to submit a pick", %{
      conn: conn,
      user: user
    } do
      league = insert(:fantasy_league)
      sport = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sport)

      championship =
        insert(:championship, category: "overall", in_season_draft: true, sports_league: sport)

      team_a = insert(:fantasy_team, fantasy_league: league)
      insert(:owner, user: user, fantasy_team: team_a)

      pick1 =
        insert(:fantasy_player, sports_league: sport, draft_pick: true, player_name: "KD Pick #1")

      pick_asset1 = insert(:roster_position, fantasy_team: team_a, fantasy_player: pick1)

      horse =
        insert(:fantasy_player, sports_league: sport, draft_pick: false, player_name: "My Horse")

      drafted_queue = insert(:draft_queue, fantasy_team: team_a, fantasy_player: horse)

      in_season_draft_pick =
        insert(
          :in_season_draft_pick,
          draft_pick_asset: pick_asset1,
          championship: championship,
          position: 1
        )

      chat = insert(:chat, room_name: "#{championship.title}:#{league.id}")

      insert(:fantasy_league_draft,
        fantasy_league: league,
        championship: championship,
        chat: chat
      )

      team2 = insert(:fantasy_team, fantasy_league: league)

      unavailable_queue =
        insert(:draft_queue, fantasy_team: team2, fantasy_player: horse, order: 1)

      horse2 =
        insert(:fantasy_player, sports_league: sport, draft_pick: false, player_name: "My Horse")

      reordered_queue =
        insert(:draft_queue, fantasy_team: team2, fantasy_player: horse2, order: 2)

      {:ok, view, _html} =
        live(conn, ~p"/fantasy_leagues/#{league.id}/championships/#{championship.id}")

      assert has_element?(view, "h3", "Draft")
      refute has_element?(view, "td", horse.player_name)

      view
      |> element("a", "Submit Pick")
      |> render_click()

      assert_patch(
        view,
        ~p"/fantasy_leagues/#{league.id}/championships/#{championship.id}/in_season_draft_picks/#{in_season_draft_pick}/edit"
      )

      view
      |> form("#in-season-draft-pick-form", %{
        in_season_draft_pick: %{drafted_player_id: nil}
      })
      |> render_change() =~ "can&#39;t be blank"

      view
      |> form("#in-season-draft-pick-form", %{
        in_season_draft_pick: %{drafted_player_id: nil}
      })
      |> render_submit() =~ "can&#39;t be blank"

      view
      |> form("#in-season-draft-pick-form", %{
        in_season_draft_pick: %{drafted_player_id: horse.id}
      })
      |> render_submit()

      assert has_element?(view, "td", horse.player_name)

      assert Repo.get!(DraftQueue, unavailable_queue.id).status == :unavailable
      assert Repo.get!(DraftQueue, drafted_queue.id).status == :drafted
      assert Repo.get!(DraftQueue, reordered_queue.id).status == :pending
      assert Repo.get!(DraftQueue, reordered_queue.id).order == 1

      assert_email_sent(fn email ->
        assert email.subject =~ "338 Draft"
      end)
    end

    test "redirects to show if user is not owner", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)

      sport = insert(:sports_league)

      championship =
        insert(:championship, category: "overall", in_season_draft: true, sports_league: sport)

      player = insert(:fantasy_player, draft_pick: true, sports_league: sport)
      pick_asset = insert(:roster_position, fantasy_team: team, fantasy_player: player)

      in_season_draft_pick =
        insert(:in_season_draft_pick, position: 1, draft_pick_asset: pick_asset)

      {:error, {:live_redirect, %{to: path}}} =
        live(
          conn,
          ~p"/fantasy_leagues/#{league.id}/championships/#{championship.id}/in_season_draft_picks/#{in_season_draft_pick}/edit"
        )

      assert path == ~p"/fantasy_leagues/#{league.id}/championships/#{championship.id}"
    end
  end

  describe "championship_live show/2 with admin user" do
    setup :register_and_log_in_admin

    test "allows admin to create in season draft picks when non exist", %{conn: conn} do
      league = insert(:fantasy_league)
      team_a = insert(:fantasy_team, fantasy_league: league)
      team_b = insert(:fantasy_team, fantasy_league: league)

      sport = insert(:sports_league)

      championship =
        insert(:championship, category: "overall", in_season_draft: true, sports_league: sport)

      player_1 =
        insert(:fantasy_player, player_name: "KD Pick #1", sports_league: sport, draft_pick: true)

      player_2 =
        insert(:fantasy_player, player_name: "KD Pick #2", sports_league: sport, draft_pick: true)

      player_3 =
        insert(:fantasy_player, player_name: "KD Pick #3", sports_league: sport, draft_pick: true)

      insert(:roster_position, fantasy_player: player_1, fantasy_team: team_a)
      insert(:roster_position, fantasy_player: player_2, fantasy_team: team_b)
      insert(:roster_position, fantasy_player: player_3, fantasy_team: team_a)

      {:ok, view, _html} =
        live(conn, ~p"/fantasy_leagues/#{league.id}/championships/#{championship.id}")

      html =
        view
        |> element("button", "Create Draft Picks")
        |> render_click()

      assert html =~ "3 picks successfully created."

      refute has_element?(view, "button", "Create Draft Picks")

      results = Repo.all(InSeasonDraftPick)

      assert Enum.count(results) == 3
    end

    test "handles error when creating draft picks", %{conn: conn} do
      league = insert(:fantasy_league)
      team_a = insert(:fantasy_team, fantasy_league: league)
      team_b = insert(:fantasy_team, fantasy_league: league)

      sport = insert(:sports_league)

      championship =
        insert(:championship, category: "overall", in_season_draft: true, sports_league: sport)

      player_1 =
        insert(:fantasy_player, player_name: "Wrong Name", sports_league: sport, draft_pick: true)

      player_2 =
        insert(:fantasy_player, player_name: "KD Pick #2", sports_league: sport, draft_pick: true)

      player_3 =
        insert(:fantasy_player, player_name: "KD Pick #3", sports_league: sport, draft_pick: true)

      insert(:roster_position, fantasy_player: player_1, fantasy_team: team_a)
      insert(:roster_position, fantasy_player: player_2, fantasy_team: team_b)
      insert(:roster_position, fantasy_player: player_3, fantasy_team: team_a)

      {:ok, view, _html} =
        live(conn, ~p"/fantasy_leagues/#{league.id}/championships/#{championship.id}")

      html =
        view
        |> element("button", "Create Draft Picks")
        |> render_click()

      assert html =~ "Error when creating draft picks"

      assert has_element?(view, "button", "Create Draft Picks")

      results = Repo.all(InSeasonDraftPick)
      assert Enum.count(results) == 0
    end

    test "allows admin to create in season draft chat", %{conn: conn} do
      league = insert(:fantasy_league)

      championship =
        insert(:championship, category: "overall", in_season_draft: true)

      {:ok, view, _html} =
        live(conn, ~p"/fantasy_leagues/#{league.id}/championships/#{championship.id}")

      html =
        view
        |> element("button", "Create Chat")
        |> render_click()

      assert html =~ "Successfully created chat for in season draft"

      refute has_element?(view, "button", "Create Draft Chat")
      assert has_element?(view, "form#create-message-form")
    end
  end
end
