defmodule Ex338Web do
  @moduledoc """
  A module that keeps using definitions for controllers,
  views and so on.

  This can be used in your application as:

      use Ex338.Web, :controller
      use Ex338.Web, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below.
  """

  def static_paths do
    default_static_paths() ++ favicon_static_paths()
  end

  def default_static_paths do
    ~w(assets fonts images themes favicon.ico robots.txt)
  end

  def favicon_static_paths do
    ~w(apple-touch-icon favicon mstile)
  end

  def controller do
    quote do
      use Phoenix.Controller,
        formats: [:html, :json],
        layouts: [html: {Ex338Web.Layouts, :app}]

      import Ecto
      import Ecto.Query
      import Ex338Web.Gettext
      import Phoenix.LiveView.Controller
      import Plug.Conn

      alias Ex338.Repo

      unquote(verified_routes())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {Ex338Web.Layouts, :app}

      unquote(html_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(html_helpers())
    end
  end

  def router do
    quote do
      use Phoenix.Router

      import Ex338Web.Authorization, only: [authorize_admin: 2]
      import Phoenix.Controller
      import Phoenix.LiveView.Router
      import Plug.Conn
    end
  end

  def channel do
    quote do
      use Phoenix.Channel

      import Ecto
      import Ecto.Query
      import Ex338Web.Gettext

      alias Ex338.Repo
    end
  end

  def html do
    quote do
      use Phoenix.Component

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # include while migrating to Phoenix.Component
      import Phoenix.View

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      # HTML escaping functionality, Core UI components and translation
      import Ex338Web.CoreComponents
      import Ex338Web.Gettext
      import Ex338Web.HTMLHelpers
      import Phoenix.HTML

      # Shortcut for generating JS commands
      alias Phoenix.LiveView.JS

      # Routes generation with the ~p sigil
      unquote(verified_routes())
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: Ex338Web.Endpoint,
        router: Ex338Web.Router,
        statics: Ex338Web.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
