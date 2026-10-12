# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :firmware_model do
      primary_key :id

      foreign_key :firmware_id, :firmware, null: false, on_update: :cascade, on_delete: :cascade
      foreign_key :model_id, :model, null: false, on_update: :cascade, on_delete: :cascade

      column :created_at, :timestamp, null: false, default: Sequel::CURRENT_TIMESTAMP
      column :updated_at, :timestamp, null: false, default: Sequel::CURRENT_TIMESTAMP
    end

    add_index :firmware_model, %i[firmware_id model_id], unique: true
  end
end
