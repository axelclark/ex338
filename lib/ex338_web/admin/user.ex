defmodule Ex338Web.ExAdmin.User do
  @moduledoc false
  use ExAdmin.Register

  register_resource Ex338.User do
    filter(only: [:name, :email, :admin])

    index do
      selectable_column

      column(:id)
      column(:name)
      column(:email)
      column(:slack_name)
      column(:admin)

      actions
    end

    show user do
      attributes_table do
        row(:name)
        row(:email)
        row(:slack_name)
        row(:admin)
        row(:invited_by_id)
        row(:invitation_accepted_at)
      end
    end

    form user do
      inputs do
        input(user, :name)
        input(user, :email)
        input(user, :slack_name)
        input(user, :admin)
      end
    end
  end
end
