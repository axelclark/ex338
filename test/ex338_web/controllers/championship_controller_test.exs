defmodule Ex338Web.ChampionshipControllerTest do
  use Ex338Web.ConnCase

  import Phoenix.LiveViewTest

  alias Ex338.CalendarAssistant
  alias Ex338.InSeasonDraftPicks

  describe "index/2" do
    test "lists all championships", %{conn: conn} do
      f_league = insert(:fantasy_league, year: 2017)
      s_league_a = insert(:sports_league)
      s_league_b = insert(:sports_league)
      insert(:league_sport, fantasy_league: f_league, sports_league: s_league_a)
      insert(:league_sport, fantasy_league: f_league, sports_league: s_league_b)
      championship_a = insert(:championship, sports_league: s_league_a)
      championship_b = insert(:championship, sports_league: s_league_b)

      conn = get(conn, fantasy_league_championship_path(conn, :index, f_league.id))

      assert html_response(conn, 200) =~ ~r/Championships/
      assert String.contains?(conn.resp_body, championship_a.title)
      assert String.contains?(conn.resp_body, championship_b.title)
      assert String.contains?(conn.resp_body, championship_b.sports_league.abbrev)
    end
  end

  describe "show/2" do
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

      conn =
        get(conn, fantasy_league_championship_path(conn, :show, f_league.id, championship.id))

      assert html_response(conn, 200) =~ ~r/Results/
      assert String.contains?(conn.resp_body, championship.title)
      assert String.contains?(conn.resp_body, to_string(result.points))
      assert String.contains?(conn.resp_body, champ_player.player_name)
      assert String.contains?(conn.resp_body, team_with_champ.team_name)
      assert String.contains?(conn.resp_body, slot_player.player_name)
      assert String.contains?(conn.resp_body, team_with_slot.team_name)
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

      conn =
        get(conn, fantasy_league_championship_path(conn, :show, f_league.id, championship.id))

      assert html_response(conn, 200) =~ ~r/Results/
      assert String.contains?(conn.resp_body, championship.title)
      assert String.contains?(conn.resp_body, to_string(result.points))
      assert String.contains?(conn.resp_body, champ_player.player_name)
      assert String.contains?(conn.resp_body, team_with_champ.team_name)
      assert String.contains?(conn.resp_body, slot_player.player_name)
      assert String.contains?(conn.resp_body, team_with_slot.team_name)
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

      conn =
        get(conn, fantasy_league_championship_path(conn, :show, f_league.id, championship.id))

      assert html_response(conn, 200) =~ ~r/Results/
      assert String.contains?(conn.resp_body, championship.title)
      assert String.contains?(conn.resp_body, to_string(result.points))
      assert String.contains?(conn.resp_body, champ_player.player_name)
      assert String.contains?(conn.resp_body, team_with_champ.team_name)
      assert String.contains?(conn.resp_body, slot_player.player_name)
      assert String.contains?(conn.resp_body, team_with_slot.team_name)
      assert String.contains?(conn.resp_body, "Overall Standings")
      assert String.contains?(conn.resp_body, "#{championship.title} Results")
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
          position: 2
        )

      conn = assign(conn, :live_module, Ex338Web.ChampionshipLive)

      {:ok, view, html} =
        live(
          conn,
          fantasy_league_championship_path(conn, :show, league.id, championship.id)
        )

      assert html =~ ~r/Draft/
      assert String.contains?(html, team_a.team_name)
      assert String.contains?(html, horse.player_name)
      assert String.contains?(html, team_b.team_name)
      refute String.contains?(html, horse2.player_name)

      InSeasonDraftPicks.draft_player(in_season_draft_pick, %{
        "drafted_player_id" => horse2.id
      })

      assert render(view) =~ horse2.player_name
    end
  end
end
