# frozen_string_literal: true

ROM::SQL.migration do
  up do
    alter_table :device_log do
      set_column_type :special_function, String
      rename_column :special_function, :command
    end

    run "DROP TYPE IF EXISTS special_function_enum CASCADE;"
  end

  down do
    run "CREATE TYPE special_function_enum AS ENUM " \
        "('identify', 'sleep', 'add_wifi', 'restart_playlist', 'rewind', 'send_to_me', 'none');"

    alter_table :device_log do
      set_column_type :command, :special_function_enum, using: "command::special_function_enum"
      rename_column :command, :special_function
    end
  end
end
