# frozen_string_literal: true

Hanami.app.register_provider :chromium do
  prepare { require "terminus/chromium/browser" }

  start { register :chromium, Terminus::Chromium::Browser.new }

  stop { slice[:chromium].quit }
end
