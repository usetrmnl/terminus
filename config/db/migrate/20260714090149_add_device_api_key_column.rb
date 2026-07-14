# frozen_string_literal: true

ROM::SQL.migration do
  change do
    add_column :device, :api_key, String
    add_index :device, :api_key, unique: true, where: "api_key IS NOT NULL"
  end
end
