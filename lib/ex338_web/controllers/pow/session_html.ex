defmodule Ex338Web.Pow.SessionHTML do
  use Ex338Web, :html

  def new(assigns) do
    ~H"""
    <div class="flex items-center justify-center min-h-screen px-4 py-2 sm:px-6 lg:px-8">
      <div class="w-full max-w-md">
        <div>
          <h2 class="text-3xl font-extrabold text-center text-gray-900 leading-9">
            Sign in to The 338 Challenge
          </h2>
        </div>
        <div class="mt-8">
          <.simple_form :let={f} for={@changeset} as={:user} action={@action} class="!bg-gray-200">
            <.error :if={@changeset.action}>
              Oops, something went wrong! Please check the errors below.
            </.error>
            <.input field={f[:email]} type="email" label="Email" />
            <.input field={f[:password]} type="password" label="Password" />
            <div class="flex items-center justify-end mt-6">
              <div class="text-sm leading-5">
                <.link
                  href={~p"/reset-password/new"}
                  class="font-medium text-indigo-600 hover:text-indigo-500 focus:outline-none focus:underline transition ease-in-out duration-150"
                >
                  Reset password
                </.link>
              </div>
            </div>
            <:actions>
              <button
                type="submit"
                class="relative flex justify-center w-full px-4 py-2 text-sm font-medium text-white bg-indigo-600 border border-transparent group leading-5 rounded-md hover:bg-indigo-500 focus:outline-none focus:border-indigo-700 focus:shadow-outline-indigo active:bg-indigo-700 transition duration-150 ease-in-out"
              >
                <span class="absolute inset-y-0 left-0 flex items-center pl-3">
                  <svg
                    class="w-5 h-5 text-indigo-500 group-hover:text-indigo-400 transition ease-in-out duration-150"
                    fill="currentColor"
                    viewBox="0 0 20 20"
                  >
                    <path
                      fill-rule="evenodd"
                      d="M5 9V7a5 5 0 0110 0v2a2 2 0 012 2v5a2 2 0 01-2 2H5a2 2 0 01-2-2v-5a2 2 0 012-2zm8-2v2H7V7a3 3 0 016 0z"
                      clip-rule="evenodd"
                    />
                  </svg>
                </span>
                Sign in
              </button>
            </:actions>
          </.simple_form>
        </div>
      </div>
    </div>
    """
  end
end
