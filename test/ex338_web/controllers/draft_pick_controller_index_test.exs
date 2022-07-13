defmodule Ex338Web.DraftPickControllerIndexTest do
  use Ex338Web.ConnCase
  import Phoenix.LiveViewTest

  alias Ex338.{DraftPicks}

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

      conn = assign(conn, :live_module, Ex338Web.DraftPickLive)

      {:ok, view, html} = live(conn, fantasy_league_draft_pick_path(conn, :index, league.id))

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

      conn = assign(conn, :live_module, Ex338Web.DraftPickLive)

      {:ok, view, html} = live(conn, fantasy_league_draft_pick_path(conn, :index, league.id))

      assert String.contains?(html, player.player_name)
      assert String.contains?(html, other_player.player_name)

      live_view = render_change(view, :filter, %{sports_league_id: sport.id, fantasy_team_id: ""})

      assert live_view =~ player.player_name
      refute live_view =~ other_player.player_name
    end
  end
end
