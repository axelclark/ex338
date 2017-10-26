defmodule Ex338Web.ExAdmin.FantasyTeam do
  @moduledoc false

  use ExAdmin.Register

  register_resource Ex338.FantasyTeam do

    show fantasy_team do
      attributes_table do
        row :id
        row :team_name
        row :waiver_position
        row :fantasy_league
        row :winnings_adj
        row :dues_paid
        row :winnings_received
        row :commish_notes, type: :text
      end
      panel "Roster Positions" do
        table_for(Enum.sort(fantasy_team.roster_positions, &(&1.position <= &2.position))) do
          column "Id", fn(position) ->
             Phoenix.HTML.safe_to_string(Phoenix.HTML.Link.link "#{position.id}", to: "/admin/roster_positions/#{position.id}/edit")
          end
          column "Position", fn(position) ->
            "#{position.position}"
          end
          column "Fantasy Player", fn(position) ->
            "#{position.fantasy_player.player_name}"
          end
          column "Sports League", fn(position) ->
            "#{position.fantasy_player.sports_league.league_name}"
          end
          column "Status", fn(position) ->
            "#{position.status}"
          end
        end
      end
    end

    query do
      %{
        all: [preload: [:fantasy_league, roster_positions:
             [fantasy_player: :sports_league]]],
      }
    end
  end
end



