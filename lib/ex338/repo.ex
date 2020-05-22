defmodule Ex338.Repo do
  use Ecto.Repo,
    otp_app: :ex338,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 20
end
