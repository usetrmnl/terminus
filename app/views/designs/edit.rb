# frozen_string_literal: true

require "core"

module Terminus
  module Views
    module Designs
      # The edit view.
      class Edit < View
        include Deps[screen_repository: "repositories.screen"]

        expose :template
        expose(:screens) { |template:| screen_repository.where template_id: template.id }
        expose(:current_screen_id) { |screens| screens.any? ? screens.first.id : 0 }
        expose :fields, default: Core::EMPTY_HASH
        expose :errors, default: Core::EMPTY_HASH
      end
    end
  end
end
