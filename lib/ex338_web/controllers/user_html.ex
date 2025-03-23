defmodule Ex338Web.UserHTML do
  use Ex338Web, :html

  def edit(assigns) do
    ~H"""
    <.two_col_form :let={f} for={@changeset} action={~p"/users/#{@user}"}>
      <:title>
        Update User Info
      </:title>
      <:description>
        Update the info for {@user.name}
      </:description>
      <.input field={f[:name]} label="Name" type="text" />
      <.input field={f[:email]} label="Email" type="email" />

      <p class="mt-2 text-sm text-gray-500">
        * Your profile image uses the
        <a class="text-indigo-700" href="https://en.gravatar.com/">Gravatar</a>
        image connected to your email.
        If you don't have a Gravatar set up, the default image will be blank.
      </p>

      <.input field={f[:slack_name]} label="Slack Username" type="text" />

      <:actions>
        <.submit_buttons back_route={~p"/users/#{@user}"} />
      </:actions>
    </.two_col_form>
    """
  end

  def show(assigns) do
    ~H"""
    <div class="grid grid-cols-1 gap-6 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4">
      <div class="flex flex-col text-center bg-white rounded-lg shadow col-span-1">
        <div class="flex flex-col flex-1 p-8">
          <.user_profile_image
            user={@user}
            class="flex-shrink-0 w-32 h-32 mx-auto bg-black rounded-full"
          />
          <h3 class="mt-6 font-medium text-gray-900 tex leading-5">{@user.name}</h3>
          <dl class="flex flex-col justify-between flex-grow mt-1">
            <dt class="sr-only">Email</dt>
            <dd class="text-sm text-gray-500 leading-5">{@user.email}</dd>
            <dt class="sr-only">Slack</dt>
            <dd class="text-sm text-gray-500 leading-5">slack: {@user.slack_name || "--"}</dd>
          </dl>
          <%= if (@current_user.id == @user.id) || (@current_user.admin == true) do %>
            <div class="flex justify-center mt-4">
              <span class="inline-flex rounded-md shadow-sm">
                <.link
                  href={~p"/users/#{@user.id}/edit"}
                  class="inline-flex items-center px-4 py-2 text-base font-medium text-white bg-indigo-600 border border-transparent leading-6 rounded-md hover:bg-indigo-500 focus:outline-none focus:border-indigo-700 focus:shadow-outline-indigo active:bg-indigo-700 transition ease-in-out duration-150"
                >
                  Update Info
                </.link>
              </span>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
