defmodule Ex338.User.Store do
  @moduledoc false

  alias Ex338.{User, Repo}

  def get_admin_emails() do
    Repo.all(User.admin_emails)
  end
end
