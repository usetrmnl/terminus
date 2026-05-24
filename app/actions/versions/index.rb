# frozen_string_literal: true

require "milestoner"

module Terminus
  module Actions
    module Versions
      class Index < Action
        include Initable[view: Milestoner::Views::Milestones::Index.new]

        def handle(*, response) = response.render view, tags: []
      end
    end
  end
end
