# frozen_string_literal: true

require "dry/core"

module Terminus
  module Aspects
    module Extensions
      module Fetchers
        # A request for HTTP purposes.
        Request = Data.define :headers, :verb, :uri, :body do
          def initialize uri:,
                         headers: Dry::Core::EMPTY_HASH,
                         verb: "get",
                         body: Dry::Core::EMPTY_HASH
            super
          end
        end
      end
    end
  end
end
