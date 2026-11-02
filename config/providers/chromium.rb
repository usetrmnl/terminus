# frozen_string_literal: true

Hanami.app.register_provider :chromium do
  prepare { require "terminus/chromium" }

  start { register :chromium, Terminus::Chromium.new }
end
