# frozen_string_literal: true

require "core"

module Terminus
  module Aspects
    module Extensions
      module Fetchers
        # Captures HTTP request details.
        Request = Data.define :headers, :verb, :uri, :body do
          def initialize uri:, headers: Core::EMPTY_HASH, verb: "get", body: Core::EMPTY_HASH
            super
          end

          def http_options
            Hash(body).empty? ? Core::EMPTY_HASH : {json: body}
          end
        end
      end
    end
  end
end
