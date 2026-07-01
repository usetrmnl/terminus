# frozen_string_literal: true

module Terminus
  module Views
    module Models
      # The index view.
      class Index < Hanami::View
        expose :models, decorate: true
        expose :query
      end
    end
  end
end
