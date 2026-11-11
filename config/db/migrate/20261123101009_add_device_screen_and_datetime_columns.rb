# frozen_string_literal: true

ROM::SQL.migration do
  change do
    alter_table :device do
      add_foreign_key :screen_id, :screen, on_update: :cascade, on_delete: :set_null
      add_column :screen_duration, :integer, null: false, default: 0
      add_column :setup_at, :timestamp
      add_column :paused_at, :timestamp
    end
  end
end
