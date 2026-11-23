# frozen_string_literal: true

ROM::SQL.migration do
  up { alter_table(:device) { set_column_default :command, "screen_forward" } }
  down { alter_table(:device) { set_column_default :command, "screen_forward" } }
end
