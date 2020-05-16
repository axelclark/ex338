defmodule Ex338.FantasyTeams do
  @moduledoc """
  The FantasyTeams context.
  """

  import Ecto.Query, warn: false
  alias Ex338.Repo

  alias Ex338.FantasyTeams.FantasyTeam

  @doc """
  Returns the list of fantasy_teams.

  ## Examples

      iex> list_fantasy_teams()
      [%FantasyTeam{}, ...]

  """
  def list_fantasy_teams do
    raise "TODO"
  end

  @doc """
  Gets a single fantasy_team.

  Raises if the Fantasy team does not exist.

  ## Examples

      iex> get_fantasy_team!(123)
      %FantasyTeam{}

  """
  def get_fantasy_team!(id), do: raise "TODO"

  @doc """
  Creates a fantasy_team.

  ## Examples

      iex> create_fantasy_team(%{field: value})
      {:ok, %FantasyTeam{}}

      iex> create_fantasy_team(%{field: bad_value})
      {:error, ...}

  """
  def create_fantasy_team(attrs \\ %{}) do
    raise "TODO"
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
    raise "TODO"
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
    raise "TODO"
  end

  @doc """
  Returns a data structure for tracking fantasy_team changes.

  ## Examples

      iex> change_fantasy_team(fantasy_team)
      %Todo{...}

  """
  def change_fantasy_team(%FantasyTeam{} = fantasy_team, _attrs \\ %{}) do
    raise "TODO"
  end
end
