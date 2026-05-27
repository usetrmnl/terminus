# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_enum :extension_on_exchange_error_enum, %w[render skip]
    add_column :extension, :on_exchange_error, :extension_on_exchange_error_enum, null: false, default: "render"
  end
end
