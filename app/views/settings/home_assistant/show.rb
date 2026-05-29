# frozen_string_literal: true

require "core"

module Terminus
  module Views
    module Settings
      module HomeAssistant
        # The show view.
        class Show < View
          expose :connection
          expose :ha_fields, default: Core::EMPTY_HASH
          expose :errors, default: Core::EMPTY_HASH
        end
      end
    end
  end
end
