# frozen_string_literal: true

require "core"

module Terminus
  module Aspects
    module Extensions
      module Fetchers
        # The input for HTTP requests.
        Input = Data.define :headers, :verb, :uri, :body do
          def initialize uri:, headers: Core::EMPTY_HASH, verb: "get", body: Core::EMPTY_HASH
            super
          end
        end
      end
    end
  end
end
