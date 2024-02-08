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

  def controller do
    quote do
      use Phoenix.Controller, layouts: [html: {Ex338Web.LayoutView, :app}]

      import Ecto
      import Ecto.Query
      import Ex338Web.Gettext
      import Phoenix.LiveView.Controller
      import Plug.Conn

      alias Ex338.Repo
      alias Ex338Web.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/ex338_web/templates",
        namespace: Ex338Web

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [view_module: 1]

      # Include shared imports and aliases for views
      unquote(view_helpers())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {Ex338Web.LayoutView, :live}

      unquote(view_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(view_helpers())
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

  defp view_helpers do
    quote do
      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      # Import LiveView helpers (live_render, live_component, live_patch, etc)

      # Import basic rendering functionality (render, render_layout, etc)
      import Ex338Web.ErrorHelpers
      import Ex338Web.Gettext
      import Ex338Web.InputHelpers
      import Ex338Web.LiveHelpers
      import Ex338Web.SharedComponents
      import Ex338Web.ViewHelpers
      import Phoenix.Component
      import Phoenix.View

      alias Ex338Web.Router.Helpers, as: Routes
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
