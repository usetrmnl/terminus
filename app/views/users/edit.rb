# frozen_string_literal: true

require "core"

module Terminus
  module Views
    module Users
      # The edit view.
      class Edit < View
        expose :user
        expose :statuses
        expose :fields, default: Core::EMPTY_HASH
        expose :errors, default: Core::EMPTY_HASH
      end
    end
  end
end
