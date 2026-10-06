# frozen_string_literal: true

ROM::SQL.migration do
  up do
    alter_table :firmware do
      add_foreign_key :model_id, :model, index: true, on_update: :cascade, on_delete: :cascade
      drop_column :kind
    end
  end

  down do
    alter_table :firmware do
      drop_column :model_id
      add_column :kind, String, null: false, default: "terminus"
    end
  end
end
