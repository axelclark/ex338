defmodule Ex338Web.UserView do
  use Ex338Web, :view

  alias Ex338.{Accounts.User}

  def user_profile_image(%User{} = user, img_opts) do
    user.email
    |> Exgravatar.gravatar_url(s: 256, d: "mp")
    |> img_tag(img_opts)
  end
end
