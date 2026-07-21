# frozen_string_literal: true

ROM::SQL.migration do
  change { add_column :device, :command, String, null: false, default: "none" }
end
