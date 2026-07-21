# auto_register: false
# frozen_string_literal: true

require "sidekiq"

module Terminus
  module Jobs
    # The base abstract class for which all jobs inherit from.
    class Base
      include Deps[:logger]
      include Sidekiq::Job

      sidekiq_options queue: "within_1_hour"
    end
  end
end
