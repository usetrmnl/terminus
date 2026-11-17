# frozen_string_literal: true

Hanami.app.register_provider :boot do
  start do
    slice.start :sidekiq
    Terminus::Aspects::Jobs::Booter.new.call
  end
end
