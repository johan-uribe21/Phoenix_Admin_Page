defmodule PharmaDashWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :pharma_dash

  socket("/socket", PharmaDashWeb.UserSocket,
    websocket: true,
    longpoll: false
  )

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug(Plug.Static,
    at: "/",
    from: :pharma_dash,
    gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)
  )

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug(Phoenix.CodeReloader)
  end

  plug(Plug.RequestId)
  plug(Plug.Telemetry, event_prefix: [:phoenix, :endpoint])

  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()
  )

  plug(Plug.MethodOverride)
  plug(Plug.Head)

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug(Plug.Session,
    store: :cookie,
    key: "_pharma_dash_key",
    signing_salt: "IjINi6Qp"
  )

  plug(Corsica,
    origins: "http://localhost:8080",
    log: [rejected: :error, invalid: :warn, accepted: :debug],
    allow_headers: ["content-type"],
    allow_credentials: true
  )

  plug(PharmaDashWeb.Router)
end
