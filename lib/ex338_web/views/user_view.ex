defmodule Ex338Web.UserView do
  use Ex338Web, :view

  alias Ex338.{Accounts.User}

  def user_profile_image(%User{} = user) do
    user.email
    |> Exgravatar.gravatar_url(s: 256, d: "blank")
    |> img_tag(border: "1")
  end
end
