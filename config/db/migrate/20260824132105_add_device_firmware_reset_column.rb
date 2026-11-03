# frozen_string_literal: true

ROM::SQL.migration do
  change { add_column :device, :firmware_reset, :boolean, null: false, default: false }
end
