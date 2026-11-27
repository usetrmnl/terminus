# frozen_string_literal: true

require "hanami/prepare"

Hanami.app.start :shrine
Hanami.app.start :sidekiq
