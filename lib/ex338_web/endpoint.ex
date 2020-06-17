defmodule Ex338Web.Endpoint do
  use Phoenix.Endpoint, otp_app: :ex338

  @session_options [
    store: :cookie,
    key: "_ex338_key",
    signing_salt: "k6OGtovU"
  ]

  socket("/socket", Ex338Web.UserSocket, websocket: true, longpoll: false)
  socket("/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]])

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  plug(
    Plug.Static,
    at: "/",
    from: :ex338,
    gzip: false,
    only: ~w(css fonts images js themes robots.txt)
  )

  plug(
    Plug.Static,
    at: "/",
    from: :ex338,
    gzip: false,
    only_matching: ~w(apple-touch-icon favicon mstile)
  )

  plug(
    Plug.Static,
    at: "/.well-known",
    from: ".well-known/",
    gzip: false,
    only: ~w(brave-payments-verification.txt)
  )

  plug(Plug.Static,
    at: "/kaffy",
    from: :kaffy,
    gzip: false,
    only: ~w(assets)
  )

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket("/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket)
    plug(Phoenix.LiveReloader)
    plug(Phoenix.CodeReloader)
  end

  plug(Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"
  )

  plug(Plug.RequestId)
  plug(Plug.Logger)

  plug(
    Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Jason
  )

  plug(Plug.MethodOverride)
  plug(Plug.Head)

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug(Plug.Session, @session_options)

  plug(Pow.Plug.Session, otp_app: :ex338)

  plug(PowPersistentSession.Plug.Cookie)

  plug(Ex338Web.Router)
end
