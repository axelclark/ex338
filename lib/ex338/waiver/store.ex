defmodule Ex338.Waiver.Store do
  @moduledoc false

  use Ex338Web, :model

  alias Ex338.{Waiver, Waiver.WaiverAdmin, Waiver.Batch, Repo}

  def create_waiver(fantasy_team, waiver_params) do
    result =
      fantasy_team
      |> build_assoc(:waivers)
      |> Waiver.new_changeset(waiver_params)
      |> Repo.insert()

    case result do
      {:ok, %Waiver{add_fantasy_player_id: nil}} = {:ok, waiver} ->
        process_new_drop_only_waiver(waiver)

      {:ok, waiver} ->
        {:ok, waiver}

      {:error, waiver_changeset} ->
        {:error, waiver_changeset}
    end
  end

  def find_waiver(waiver_id) do
    Waiver
    |> Waiver.preload_assocs()
    |> Repo.get(waiver_id)
  end

  def get_all_waivers(league_id) do
    Waiver
    |> Waiver.by_league(league_id)
    |> Waiver.preload_assocs()
    |> Repo.all()
  end

  def get_all_pending_waivers() do
    Waiver
    |> Waiver.preload_assocs()
    |> Waiver.pending()
    |> Waiver.ready_to_process()
    |> Repo.all()
  end

  def batch_process_all() do
    case get_all_pending_waivers() do
      [] ->
        :ok

      waivers ->
        waivers
        |> Batch.group_and_sort()
        |> List.first()
        |> process_batch

        batch_process_all()
    end
  end

  def process_batch([]), do: :ok

  def process_batch([first | rest]) do
    case process_successful(first) do
      {:ok, _waiver} ->
        Enum.each(rest, &process_unsuccessful/1)

      {:error, _waiver} ->
        process_invalid(first)
        process_batch(rest)
    end
  end

  def process_waiver(waiver, params) do
    waiver
    |> WaiverAdmin.process_waiver(params)
    |> Repo.transaction()
  end

  def update_waiver(waiver, params) do
    waiver
    |> Waiver.update_changeset(params)
    |> Repo.update()
  end

  ## Helpers

  ## Implementations

  defp process_successful(waiver) do
    waiver
    |> process_waiver(%{"status" => "successful"})
    |> handle_multi_update
  end

  defp process_unsuccessful(waiver) do
    waiver
    |> process_waiver(%{"status" => "unsuccessful"})
    |> handle_multi_update
  end

  defp process_invalid(waiver) do
    waiver
    |> process_waiver(%{"status" => "invalid"})
    |> handle_multi_update
  end

  defp handle_multi_update({:ok, %{waiver: waiver}}) do
    {:ok, waiver}
  end

  defp handle_multi_update({:error, _, waiver_changeset, _}) do
    {:error, waiver_changeset}
  end

  # create_waiver

  defp process_new_drop_only_waiver(waiver), do: process_successful(waiver)
end
