# frozen_string_literal: true

module Terminus
  module Contracts
    module Devices
      module Imports
        # Defines device bulk import schema.
        class Bulk < Contract
          params { required(:rows).array(Device.schema) }
        end
      end
    end
  end
end
