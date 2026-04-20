# frozen_string_literal: true

ROM::SQL.migration do
  change do
    alter_table :model do
      add_foreign_key :default_palette_id, :palette, on_update: :cascade, on_delete: :set_null
    end
  end
end
