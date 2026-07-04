# frozen_string_literal: true

require "dry/validation"

module Terminus
  # Defines user create contract.
  class Contract < Dry::Validation::Contract
    config.messages.backend = :i18n

    Hanami.app.config.i18n.tap do |i18n|
      (i18n.shared_load_path + i18n.load_path).each do |entry|
        path = Hanami.app.root.join entry.sub(/\*.*/, "")
        config.messages.load_paths.merge path.glob("**/*.yml")
      end
    end
  end
end
