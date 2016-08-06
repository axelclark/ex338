defmodule Ex338.ExAdmin.Trade do
  use ExAdmin.Register

  register_resource Ex338.Trade do

    index do
      selectable_column

      column :id
      column :inserted_at, label: "Date"
      column :status
      column :additional_terms
      actions
    end

    form trade do
      inputs do
        input trade, :status, collection: Ex338.Trade.status_options
        input trade, :additional_terms
      end
    end

    show trade do
      attributes_table do
        row :id
        row :inserted_at, label: "Date"
        row :status
        row :additional_terms
      end
    end
  end
end
