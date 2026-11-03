# frozen_string_literal: true

ROM::SQL.migration { change { add_column :device, :panel_revision, String } }
