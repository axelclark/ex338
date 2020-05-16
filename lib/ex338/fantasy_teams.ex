defmodule Ex338.FantasyTeams do
  @moduledoc """
  The FantasyTeams context.
  """

  import Ecto.Query, warn: false
  alias Ex338.Repo

  alias Ex338.FantasyTeam

  @doc """
  Returns the list of fantasy_teams.

  ## Examples

      iex> list_fantasy_teams()
      [%FantasyTeam{}, ...]

  """
  def list_fantasy_teams do
    Repo.all(FantasyTeam)
  end

  @doc """
  Gets a single fantasy_team.

  Raises if the Fantasy team does not exist.

  ## Examples

      iex> get_fantasy_team!(123)
      %FantasyTeam{}

  """
  def get_fantasy_team!(id), do: Repo.get!(FantasyTeam, id)

  @doc """
  Creates a fantasy_team.

  ## Examples

      iex> create_fantasy_team(%{field: value})
      {:ok, %FantasyTeam{}}

      iex> create_fantasy_team(%{field: bad_value})
      {:error, ...}

  """
  def create_fantasy_team(attrs \\ %{}) do
    %FantasyTeam{}
    |> FantasyTeam.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a fantasy_team.

  ## Examples

      iex> update_fantasy_team(fantasy_team, %{field: new_value})
      {:ok, %FantasyTeam{}}

      iex> update_fantasy_team(fantasy_team, %{field: bad_value})
      {:error, ...}

  """
  def update_fantasy_team(%FantasyTeam{} = fantasy_team, attrs) do
    fantasy_team
    |> FantasyTeam.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a FantasyTeam.

  ## Examples

      iex> delete_fantasy_team(fantasy_team)
      {:ok, %FantasyTeam{}}

      iex> delete_fantasy_team(fantasy_team)
      {:error, ...}

  """
  def delete_fantasy_team(%FantasyTeam{} = fantasy_team) do
    Repo.delete(fantasy_team)
  end

  @doc """
  Returns a data structure for tracking fantasy_team changes.

  ## Examples

      iex> change_fantasy_team(fantasy_team)
      %Todo{...}

  """
  def change_fantasy_team(%FantasyTeam{} = fantasy_team, attrs \\ %{}) do
    FantasyTeam.changeset(fantasy_team, attrs)
  end
end
