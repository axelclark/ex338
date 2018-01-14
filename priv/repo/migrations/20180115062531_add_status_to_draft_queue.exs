defmodule Ex338.Repo.Migrations.AddStatusToDraftQueue do
  use Ecto.Migration

  def up do
    DraftQueueStatusEnum.create_type
    alter table("draft_queues") do
      add :status, :draft_queue_status
    end
  end

  def down do
    alter table("draft_queues") do
      remove :status
    end
    DraftQueueStatusEnum.drop_type
  end
end
