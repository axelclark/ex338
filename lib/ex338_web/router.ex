defmodule Ex338Web.Router do
  use Ex338Web, :router
  use Honeybadger.Plug

  use Kaffy.Routes,
    scope: "/admin",
    pipe_through: [:browser, :require_authenticated_user, :admin, :remove_root_layout]

  import Ex338Web.UserAuth
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:fetch_live_flash)
    plug(:put_root_layout, html: {Ex338Web.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug :fetch_current_user
    plug(Ex338Web.LoadUserTeams)
  end

  pipeline :admin do
    plug(:authorize_admin)
  end

  pipeline :load_leagues do
    plug(Ex338Web.LoadLeagues)
  end

  pipeline :remove_root_layout do
    plug(:put_root_layout, false)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  ## Authentication routes

  scope "/", Ex338Web do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    forward "/session", Plugs.UserLoginRedirector

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{Ex338Web.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", Ex338Web do
    pipe_through [:browser, :require_authenticated_user, :load_leagues]

    live_session :require_authenticated_user,
      on_mount: [{Ex338Web.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", Ex338Web do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{Ex338Web.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end

  scope "/", Ex338Web do
    pipe_through([:browser, :load_leagues])

    live_session :leagues_current_user,
      on_mount: [{Ex338Web.UserAuth, :mount_current_user}] do
      live "/fantasy_teams/:id", FantasyTeamLive.Show, :show

      scope "/fantasy_leagues/:fantasy_league_id" do
        live "/draft_picks", DraftPickLive.Index, :index
        live "/championships", ChampionshipLive.Index, :index

        live "/championships/:championship_id/in_season_draft_picks/:in_season_draft_pick_id/edit",
             ChampionshipLive.Show,
             :in_season_draft_pick_edit

        live "/championships/:championship_id", ChampionshipLive.Show, :show
      end
    end

    resources "/fantasy_leagues", FantasyLeagueController, only: [:show] do
      resources("/fantasy_teams", FantasyTeamController, only: [:index])
      resources("/fantasy_players", FantasyPlayerController, only: [:index])
      resources("/owners", OwnerController, only: [:index])
      resources("/waivers", WaiverController, only: [:index])
      resources("/trades", TradeController, only: [:index])
      resources("/injured_reserves", InjuredReserveController, only: [:index])
    end

    resources("/archived_leagues", ArchivedLeagueController, only: [:index])

    get("/rules", PageController, :rules)
    get("/", PageController, :index)
  end

  scope "/", Ex338Web do
    pipe_through([:browser, :require_authenticated_user, :load_leagues])

    live_session :leagues_require_authenticated_user,
      on_mount: [{Ex338Web.UserAuth, :ensure_authenticated}] do
      live "/fantasy_teams/:id/edit", FantasyTeamLive.Edit, :edit
      live "/fantasy_teams/:id/draft_queues/edit", FantasyTeamDraftQueuesLive.Edit, :edit
    end

    resources "/fantasy_teams", FantasyTeamController, only: [] do
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
    pipe_through([:browser, :require_authenticated_user, :admin, :load_leagues])
    resources("/commish_email", CommishEmailController, only: [:new, :create])
    resources("/table_upload", TableUploadController, only: [:new, :create])
    resources("/waiver_admin", WaiverAdminController, only: [:edit, :update])

    live_session :admin,
      on_mount: [{Ex338Web.UserAuth, :ensure_authenticated}] do
      live "/invitations/new", UserInvitationLive, :new
    end

    resources "/fantasy_leagues", FantasyLeagueController, only: [] do
      resources("/championship_slot_admin", ChampionshipSlotAdminController, only: [:create])
      resources("/in_season_draft_order", InSeasonDraftOrderController, only: [:create])
      resources("/injured_reserves", InjuredReserveController, only: [:update])
    end
  end

  scope "/commish", Ex338Web.Commish, as: :commish do
    pipe_through([:browser, :require_authenticated_user, :admin, :load_leagues])

    live_session :commish,
      on_mount: [{Ex338Web.UserAuth, :ensure_authenticated}] do
      live("/fantasy_leagues/:id/edit", FantasyLeagueLive.Edit, :edit)

      scope("/fantasy_leagues/:id") do
        live("/approvals", FantasyLeagueLive.Approval, :index)
      end
    end
  end

  scope "/" do
    pipe_through([:browser, :require_authenticated_user, :admin])
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
