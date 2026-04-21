# frozen_string_literal: true

ROM::SQL.migration do
  up { drop_column :model, :palette_names }

  down { add_column :model, :palette_names, "text[]", null: false, default: "{}" }
end
