defmodule Ex338.HistoricalRecord do
  @moduledoc false

  use Ex338Web, :model

  schema "historical_records" do
    field(:description, :string)
    field(:record, :string)
    field(:team, :string)
    field(:year, :string)
    field(:type, HistoricalRecordTypeEnum, default: "season")
    field(:archived, :boolean)

    timestamps()
  end

  def all_time_records(query) do
    from(r in query, where: r.type == "all_time")
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(record, params \\ %{}) do
    record
    |> cast(params, [:description, :record, :team, :year, :type, :archived])
    |> validate_required([:description, :record, :team, :type, :archived])
  end

  def current_records(query) do
    from(r in query, where: r.archived == false)
  end

  def season_records(query) do
    from(r in query, where: r.type == "season")
  end
end
