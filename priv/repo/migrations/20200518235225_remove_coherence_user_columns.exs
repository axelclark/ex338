defmodule Ex338.Repo.Migrations.RemoveCoherenceUserColumns do
  use Ecto.Migration

  def up do
    alter table(:users) do
      # rememberable
      remove(:remember_created_at)
      # recoverable
      remove(:reset_password_token)
      remove(:reset_password_sent_at)
      # lockable
      remove(:failed_attempts)
      remove(:locked_at)
      # trackable
      remove(:sign_in_count)
      remove(:current_sign_in_at)
      remove(:last_sign_in_at)
      remove(:current_sign_in_ip)
      remove(:last_sign_in_ip)
      # unlockable_with_token
      remove(:unlock_token)
    end
  end

  def down do
    alter table(:users) do
      # rememberable
      add(:remember_created_at, :utc_datetime)
      # recoverable
      add(:reset_password_token, :string)
      add(:reset_password_sent_at, :utc_datetime)
      # lockable
      add(:failed_attempts, :integer, default: 0)
      add(:locked_at, :utc_datetime)
      # trackable
      add(:sign_in_count, :integer, default: 0)
      add(:current_sign_in_at, :utc_datetime)
      add(:last_sign_in_at, :utc_datetime)
      add(:current_sign_in_ip, :string)
      add(:last_sign_in_ip, :string)
      # unlockable_with_token
      add(:unlock_token, :string)
    end
  end
end
