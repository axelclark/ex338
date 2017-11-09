defmodule Ex338.Waiver.Store do
  @moduledoc false

  use Ex338Web, :model

  alias Ex338.{Waiver, Waiver.WaiverAdmin, Repo}

  def create_waiver(fantasy_team, waiver_params) do
    result = fantasy_team
             |> build_assoc(:waivers)
             |> Waiver.new_changeset(waiver_params)
             |> Repo.insert

    case result do
      {:ok, %Waiver{add_fantasy_player_id: nil}} = {:ok, waiver} ->
        update_new_drop_only_waiver(waiver)
      {:ok, waiver}      ->  {:ok, waiver}
      {:error, waiver_changeset} -> {:error, waiver_changeset}
    end
  end

  def get_all_waivers(league_id) do
    Waiver
    |> Waiver.by_league(league_id)
    |> preload([[fantasy_team: :owners], [add_fantasy_player: :sports_league],
               [drop_fantasy_player: :sports_league]])
    |> Repo.all
  end

  def process_waiver(waiver, params) do
    waiver
    |> WaiverAdmin.process_waiver(params)
    |> Repo.transaction
  end

  def update_waiver(waiver, params) do
    waiver
    |> Waiver.update_changeset(params)
    |> Repo.update
  end

  ## Helpers

  ## Implementations

  # create_waiver

  defp update_new_drop_only_waiver(waiver) do
    waiver
    |> process_waiver(%{"status" => "successful"})
    |> handle_multi_update
  end

  defp handle_multi_update({:ok, %{waiver: waiver}}) do
     {:ok, waiver}
  end

  defp handle_multi_update({:error, _, waiver_changeset, _}) do
     {:error, waiver_changeset}
  end
end
