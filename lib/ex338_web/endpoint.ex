defmodule Ex338Web.Endpoint do
  use Phoenix.Endpoint, otp_app: :ex338

  socket("/socket", Ex338Web.UserSocket)

  # Wallaby config
  if Application.get_env(:ex338, :sql_sandbox) do
    plug(Phoenix.Ecto.SQL.Sandbox)
  end

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  plug(
    Plug.Static,
    at: "/",
    from: :ex338,
    gzip: false,
    only: ~w(css fonts images js themes favicon.ico robots.txt)
  )

  plug(
    Plug.Static,
    at: "/.well-known",
    from: ".well-known/",
    gzip: false,
    only: ~w(brave-payments-verification.txt)
  )

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket("/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket)
    plug(Phoenix.LiveReloader)
    plug(Phoenix.CodeReloader)
  end

  plug(Plug.RequestId)
  plug(Plug.Logger)

  plug(
    Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison
  )

  plug(Plug.MethodOverride)
  plug(Plug.Head)

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug(
    Plug.Session,
    store: :cookie,
    key: "_ex338_key",
    signing_salt: "k6OGtovU"
  )

  plug(Ex338Web.Router)
end
