# frozen_string_literal: true

Hanami.app.configure_provider :db do
  Sequel.default_timezone = :utc
  Sequel.extension :lit_require_frozen
end
