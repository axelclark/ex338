defmodule Ex338.ExAdmin.User do
  use ExAdmin.Register

  register_resource Ex338.User do

    # filter except: [:password_hash, :reset_password_token, :unlock_token]
    filter only: [:name, :email, :admin]

    index do
      selectable_column

      column :id
      column :name
      column :email
      column :admin

      actions
    end

    show user do
      attributes_table do
        row :name
        row :email
        row :admin
        row :sign_in_count
        row :current_sign_in_at
        row :last_sign_in_at
        row :reset_password_sent_at
        row :locked_at
      end
    end

    form user do
      inputs do
        input user, :name
        input user, :email
        input user, :admin
      end
    end
  end
end
