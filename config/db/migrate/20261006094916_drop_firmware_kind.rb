# frozen_string_literal: true

ROM::SQL.migration do
  up do
    alter_table :firmware do
      drop_column :kind
      drop_constraint :firmwares_version_key
    end
  end

  down do
    alter_table :firmware do
      add_column :kind, String, null: false, default: "terminus"
      add_unique_constraint :version, name: :firmwares_version_key
    end
  end
end
