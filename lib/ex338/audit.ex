defmodule Ex338.Audit do
  @moduledoc """
  Append-only audit trail for write actions (see `Ex338.Audit.AuditLog`).

  `log/1` is best-effort: it records the action but never raises into the
  caller's request flow, so an audit hiccup can't fail a user's real action.
  Callers invoke it *after* the action they are recording, outside that action's
  transaction.
  """
  import Ecto.Query

  alias Ex338.Audit.AuditLog
  alias Ex338.Repo

  require Logger

  @doc """
  Records an audit entry. Returns `{:ok, entry}`, `{:error, changeset}` for
  invalid attrs, or `{:error, :exception}` if the insert itself raises (already
  logged). Never raises.
  """
  def log(attrs) do
    %AuditLog{}
    |> AuditLog.changeset(normalize_metadata(attrs))
    |> Repo.insert()
  rescue
    error ->
      Logger.error("Audit log insert failed: #{Exception.message(error)}")
      {:error, :exception}
  end

  # Store metadata with string keys so the value is identical whether read from
  # the freshly-inserted struct or reloaded from the jsonb column.
  defp normalize_metadata(%{metadata: metadata} = attrs) when is_map(metadata) do
    Map.put(attrs, :metadata, stringify(metadata))
  end

  defp normalize_metadata(%{"metadata" => metadata} = attrs) when is_map(metadata) do
    Map.put(attrs, "metadata", stringify(metadata))
  end

  defp normalize_metadata(attrs), do: attrs

  defp stringify(map) when is_map(map) and not is_struct(map) do
    Map.new(map, fn {key, value} -> {to_string(key), stringify(value)} end)
  end

  defp stringify(list) when is_list(list), do: Enum.map(list, &stringify/1)
  defp stringify(value), do: value

  @doc """
  Maps a tagged action result onto an audit outcome string.
  """
  def outcome_for({:ok, _}), do: "success"
  def outcome_for({:error, :forbidden}), do: "denied"
  def outcome_for(_), do: "error"

  @doc """
  Lists the most recent audit entries, newest first.
  """
  def list_recent(limit \\ 50) do
    AuditLog
    |> order_by(desc: :inserted_at, desc: :id)
    |> limit(^limit)
    |> preload([:user, :fantasy_league])
    |> Repo.all()
  end

  @doc """
  Lists a user's audit entries, newest first.
  """
  def list_for_user(user_id, limit \\ 50) do
    AuditLog
    |> where(user_id: ^user_id)
    |> order_by(desc: :inserted_at, desc: :id)
    |> limit(^limit)
    |> Repo.all()
  end

  @doc """
  Lists audit entries for a specific resource, newest first.
  """
  def list_for_resource(resource_type, resource_id) do
    AuditLog
    |> where(resource_type: ^resource_type, resource_id: ^resource_id)
    |> order_by(desc: :inserted_at, desc: :id)
    |> Repo.all()
  end
end
