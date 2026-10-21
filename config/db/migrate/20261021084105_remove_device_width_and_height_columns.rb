# frozen_string_literal: true

ROM::SQL.migration do
  up do
    drop_column :device, :width
    drop_column :device, :height
  end

  down do
    add_column :device, :width, :integer, null: false, default: 0
    add_column :device, :height, :integer, null: false, default: 0
  end
end
