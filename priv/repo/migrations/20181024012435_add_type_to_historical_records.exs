defmodule Ex338.Repo.Migrations.AddTypeToHistoricalRecords do
  use Ecto.Migration

  def up do
    HistoricalRecordTypeEnum.create_type
    alter table("historical_records") do
      add :type, :historical_record_type, default: "season"
    end
  end

  def down do
    alter table("historical_records") do
      remove :type
    end
    HistoricalRecordTypeEnum.drop_type
  end
end
