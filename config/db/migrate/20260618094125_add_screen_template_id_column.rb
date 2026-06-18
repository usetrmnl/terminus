# frozen_string_literal: true

ROM::SQL.migration do
  change do
    alter_table :screen do
      add_foreign_key :template_id, :screen_template, on_update: :cascade, on_delete: :set_null
    end
  end
end
