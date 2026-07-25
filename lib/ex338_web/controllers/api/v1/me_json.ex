defmodule Ex338Web.Api.V1.MeJSON do
  def show(%{user: user}) do
    %{user: user_data(user)}
  end

  defp user_data(user) do
    %{
      id: user.id,
      name: user.name,
      email: user.email,
      admin: user.admin
    }
  end
end
