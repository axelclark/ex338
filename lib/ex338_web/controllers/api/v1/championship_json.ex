defmodule Ex338Web.Api.V1.ChampionshipJSON do
  def index(%{championships: championships}) do
    %{championships: Enum.map(championships, &championship_summary/1)}
  end

  def show(%{championship: championship}) do
    %{
      championship:
        Map.merge(championship_summary(championship), %{
          championship_results: Enum.map(championship.championship_results, &result_data/1),
          championship_slots: Enum.map(championship.championship_slots, &slot_data/1)
        })
    }
  end

  defp championship_summary(champ) do
    %{
      id: champ.id,
      title: champ.title,
      category: champ.category,
      year: champ.year,
      sports_league: champ.sports_league.abbrev,
      championship_at: champ.championship_at,
      waiver_deadline_at: champ.waiver_deadline_at,
      trade_deadline_at: champ.trade_deadline_at,
      waivers_closed: champ.waivers_closed?,
      trades_closed: champ.trades_closed?,
      season_ended: champ.season_ended?,
      in_season_draft: champ.in_season_draft
    }
  end

  defp result_data(result) do
    %{
      id: result.id,
      rank: result.rank,
      points: result.points,
      fantasy_player: %{
        id: result.fantasy_player.id,
        player_name: result.fantasy_player.player_name
      }
    }
  end

  defp slot_data(slot) do
    %{
      id: slot.id,
      slot: slot.slot,
      roster_position: roster_position_data(slot.roster_position)
    }
  end

  defp roster_position_data(%{id: id} = pos) do
    %{
      id: id,
      fantasy_team: %{
        id: pos.fantasy_team.id,
        team_name: pos.fantasy_team.team_name
      },
      fantasy_player: %{
        id: pos.fantasy_player.id,
        player_name: pos.fantasy_player.player_name
      }
    }
  end

  defp roster_position_data(_), do: nil
end
