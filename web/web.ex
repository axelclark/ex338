defmodule Ex338.Web do
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

  def model do
    quote do
      use Ecto.Schema

      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      def all, do: Ex338.Repo.all(__MODULE__)
    end
  end

  def controller do
    quote do
      use Phoenix.Controller

      alias Ex338.Repo
      import Ecto
      import Ecto.Query

      import Ex338.Router.Helpers
      import Ex338.Gettext
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "web/templates"

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2,
                                        view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import Ex338.Router.Helpers
      import Ex338.ErrorHelpers
      import Ex338.Gettext

      import Ex338.ViewHelpers
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Ex338.AuthorizeAdmin, only: [authorize_admin: 2]
    end
  end

  def channel do
    quote do
      use Phoenix.Channel

      alias Ex338.Repo
      import Ecto
      import Ecto.Query
      import Ex338.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
