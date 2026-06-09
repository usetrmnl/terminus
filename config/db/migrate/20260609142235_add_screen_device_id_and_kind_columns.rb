# frozen_string_literal: true

ROM::SQL.migration do
  change do
    alter_table :screen do
      add_foreign_key :device_id, :device, on_update: :cascade, on_delete: :cascade
    end

    create_enum :screen_kind_enum, %w[error general notification sleep wake welcome]
    add_column :screen, :kind, :screen_kind_enum, null: false, default: "general"

    add_index :screen, %i[device_id kind], unique: true, where: "device_id IS NOT NULL"
  end
end
