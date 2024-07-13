defmodule Ex338Web.DraftPickLive.IndexTest do
  use Ex338Web.ConnCase

  import Phoenix.LiveViewTest

  alias Ex338.DraftPicks

  describe "index/2" do
    test "lists all draft picks in a league and updates new pick", %{conn: conn} do
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)

      other_team =
        insert(
          :fantasy_team,
          team_name: "Another Team",
          fantasy_league: other_league
        )

      pick = insert(:draft_pick, draft_position: 1.01, fantasy_team: team, fantasy_league: league)

      _other_pick =
        insert(
          :draft_pick,
          draft_position: 1.01,
          fantasy_team: other_team,
          fantasy_league: other_league
        )

      {:ok, view, html} = live(conn, ~p"/fantasy_leagues/#{league.id}/draft_picks")

      assert html =~ ~r/Draft/
      assert String.contains?(html, Float.to_string(pick.draft_position))
      assert String.contains?(html, team.team_name)
      refute String.contains?(html, other_team.team_name)

      player = insert(:fantasy_player)
      DraftPicks.draft_player(pick, %{"fantasy_player_id" => player.id})

      assert render(view) =~ player.player_name
    end

    test "filters draft picks by sport without changing current picks", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)

      sport = insert(:sports_league)
      player = insert(:fantasy_player, sports_league: sport)
      insert(:league_sport, sports_league: sport, fantasy_league: league)

      insert(:draft_pick,
        draft_position: 1.01,
        fantasy_team: team,
        fantasy_league: league,
        drafted_at: DateTime.from_naive!(~N[2018-09-21 01:10:02.857392], "Etc/UTC"),
        fantasy_player: player
      )

      other_sport = insert(:sports_league)
      other_player = insert(:fantasy_player, sports_league: other_sport)
      insert(:league_sport, sports_league: other_sport, fantasy_league: league)

      insert(
        :draft_pick,
        draft_position: 1.02,
        fantasy_team: team,
        fantasy_league: league,
        drafted_at: DateTime.from_naive!(~N[2018-09-21 01:15:02.857392], "Etc/UTC"),
        fantasy_player: other_player
      )

      extra_sport = insert(:sports_league)
      insert(:fantasy_player, sports_league: extra_sport)
      insert(:league_sport, sports_league: extra_sport, fantasy_league: league)

      insert_list(5, :submitted_pick,
        draft_position: 1.03,
        drafted_at: DateTime.from_naive!(~N[2018-09-21 01:15:02.857392], "Etc/UTC"),
        fantasy_league: league
      )

      insert_list(5, :draft_pick, draft_position: 1.04, fantasy_league: league)

      {:ok, view, html} = live(conn, ~p"/fantasy_leagues/#{league.id}/draft_picks")

      assert String.contains?(html, player.player_name)
      assert String.contains?(html, other_player.player_name)

      live_view =
        render_change(view, :filter, %{filter: %{sports_league_id: sport.id, fantasy_team_id: ""}})

      assert live_view =~ player.player_name
      refute live_view =~ other_player.player_name
    end
  end

  describe "index/2 with logged in user" do
    setup :register_and_log_in_user

    test "allows owners to chat", %{conn: conn, user: user} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "My Great Team", fantasy_league: league)
      insert(:owner, user: user, fantasy_team: team)

      pick = insert(:draft_pick, draft_position: 1.01, fantasy_team: team, fantasy_league: league)

      chat = insert(:chat, room_name: "#{league.fantasy_league_name}")
      insert(:message, chat: chat, user: user, content: "hello world!")

      insert(:fantasy_league_draft,
        fantasy_league: league,
        chat: chat
      )

      championship =
        insert(:championship, category: "overall")

      championship_chat = insert(:chat, room_name: "#{championship.title}:#{league.id}")

      insert(:fantasy_league_draft,
        fantasy_league: league,
        championship: championship,
        chat: championship_chat
      )

      another_user = insert(:user)
      team_b = insert(:fantasy_team, fantasy_league: league, team_name: another_user.name)
      insert(:owner, user: another_user, fantasy_team: team_b)

      {:ok, view, _html} = live(conn, ~p"/fantasy_leagues/#{league.id}/draft_picks")

      assert has_element?(view, "td", "1.01")
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

      assert has_element?(view, "div", "#{user.name} - #{team.team_name}")
      assert has_element?(view, "p", "My team is awesome!")

      {:ok, _chat} =
        Ex338.Chats.create_message(%{
          "content" => "Wow",
          "user_id" => another_user.id,
          "chat_id" => chat.id
        })

      render(view)

      refute has_element?(view, "div", "#{another_user.name} - #{team_b.team_name}")
      assert has_element?(view, "div", "#{another_user.name}")
      assert has_element?(view, "p", "Wow")

      player = insert(:fantasy_player)
      {:ok, _pick} = DraftPicks.draft_player(pick, %{"fantasy_player_id" => player.id})

      assert render(view) =~ player.player_name

      draft_chat_message =
        "#{team.team_name} drafted #{player.player_name} with pick #1.01"

      assert has_element?(view, "p", draft_chat_message)
    end
  end
end
