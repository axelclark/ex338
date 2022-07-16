defmodule Ex338Web.Router do
  use Ex338Web, :router
  use Honeybadger.Plug
  use Pow.Phoenix.Router
  use Pow.Extension.Phoenix.Router, otp_app: :ex338
  import Phoenix.LiveDashboard.Router

  use Kaffy.Routes, scope: "/admin", pipe_through: [:protected, :admin, :remove_root_layout]

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {Ex338Web.LayoutView, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(Ex338Web.LoadUserTeams)
    plug(Ex338Web.RequestEvent)
  end

  pipeline :protected do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {Ex338Web.LayoutView, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)

    plug(Pow.Plug.RequireAuthenticated,
      error_handler: Pow.Phoenix.PlugErrorHandler
    )

    plug(Ex338Web.LoadUserTeams)
    plug(Ex338Web.RequestEvent)
  end

  pipeline :admin do
    plug(:authorize_admin)
  end

  pipeline :load_leagues do
    plug(Ex338Web.LoadLeagues)
  end

  pipeline :assign_current_user_to_socket do
    plug(Ex338Web.AssignCurrentUserToSocket)
  end

  pipeline :remove_root_layout do
    plug(:put_root_layout, false)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", PowInvitation.Phoenix, as: "pow_invitation" do
    pipe_through([:protected, :admin, :load_leagues])
    resources("/invitations", InvitationController, only: [:new, :create, :show])
  end

  scope "/" do
    pipe_through(:browser)

    pow_session_routes()
    pow_extension_routes()
  end

  scope "/", Pow.Phoenix, as: "pow" do
    pipe_through([:browser, :protected])

    resources("/registration", RegistrationController,
      singleton: true,
      only: [:edit, :update, :delete]
    )
  end

  scope "/", Ex338Web do
    pipe_through([:browser, :load_leagues])

    resources "/fantasy_leagues", FantasyLeagueController, only: [:show] do
      resources("/championships", ChampionshipController, only: [:index, :show])
      resources("/fantasy_teams", FantasyTeamController, only: [:index])
      resources("/fantasy_players", FantasyPlayerController, only: [:index])
      resources("/owners", OwnerController, only: [:index])
      resources("/draft_picks", DraftPickController, only: [:index])
      resources("/waivers", WaiverController, only: [:index])
      resources("/trades", TradeController, only: [:index])
      resources("/injured_reserves", InjuredReserveController, only: [:index])
    end

    resources("/fantasy_teams", FantasyTeamController, only: [:show])
    resources("/archived_leagues", ArchivedLeagueController, only: [:index])

    get("/rules", PageController, :rules)
    get("/", PageController, :index)
  end

  scope "/", Ex338Web do
    pipe_through([:protected, :load_leagues])

    resources "/fantasy_teams", FantasyTeamController, only: [:edit, :update] do
      resources("/draft_queues", DraftQueueController, only: [:new, :create])
      resources("/trade_votes", TradeVoteController, only: [:create])
      resources("/trades", TradeController, only: [:new, :create, :update])
      resources("/waivers", WaiverController, only: [:new, :create])
      resources("/injured_reserves", InjuredReserveController, only: [:new, :create])
    end

    resources("/draft_picks", DraftPickController, only: [:edit, :update])
    resources("/in_season_draft_picks", InSeasonDraftPickController, only: [:edit, :update])
    resources("/waivers", WaiverController, only: [:edit, :update])
    resources("/users", UserController, only: [:edit, :show, :update])
  end

  scope "/", Ex338Web do
    pipe_through([:protected, :admin, :load_leagues])
    resources("/commish_email", CommishEmailController, only: [:new, :create])
    resources("/table_upload", TableUploadController, only: [:new, :create])
    resources("/waiver_admin", WaiverAdminController, only: [:edit, :update])

    resources "/fantasy_leagues", FantasyLeagueController, only: [] do
      resources("/championship_slot_admin", ChampionshipSlotAdminController, only: [:create])
      resources("/in_season_draft_order", InSeasonDraftOrderController, only: [:create])
      resources("/injured_reserves", InjuredReserveController, only: [:update])
    end
  end

  scope "/commish", Ex338Web.Commish, as: :commish do
    pipe_through([:protected, :admin, :load_leagues, :assign_current_user_to_socket])

    live("/fantasy_leagues/:id/edit", FantasyLeagueLive.Edit, :edit)

    scope("/fantasy_leagues/:id") do
      live("/approvals", FantasyLeagueLive.Approval, :index)
    end
  end

  scope "/" do
    pipe_through([:protected, :admin])
    live_dashboard("/live_dashboard", metrics: Ex338Web.Telemetry)
  end

  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through([:browser])

      forward("/mailbox", Plug.Swoosh.MailboxPreview, base_path: "/dev/mailbox")
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", Ex338Web do
  #   pipe_through :api
  # end
end
