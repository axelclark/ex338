defmodule Ex338.Rulebooks do
  @moduledoc false
  use NimblePublisher,
    build: Ex338.Rulebooks.Rulebook,
    from: Application.app_dir(:ex338, "priv/rules/**/*.md"),
    as: :rulebooks

  alias Ex338.FantasyLeagues.FantasyLeague

  # And finally export them
  def all_rulebooks, do: @rulebooks

  defmodule NotFoundError, do: defexception([:message, plug_status: 404])

  def get_rulebook_for_fantasy_league!(%FantasyLeague{year: year, draft_method: draft_method}) do
    Enum.find(
      all_rulebooks(),
      &(&1.year == year and &1.draft_method == Atom.to_string(draft_method))
    ) ||
      raise NotFoundError, "rule with year=#{year} and draft_method=#{draft_method} not found"
  end
end
