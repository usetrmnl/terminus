# frozen_string_literal: true

require "liquid"

module Terminus
  module Aspects
    module Extensions
      module Importers
        module Remote
          module Transformers
            module Templates
              # A Liquid template formatter.
              class Variablizer
                # :reek:UtilityFunction
                def call node
                  "{{ #{node.raw.strip} }}"
                end
              end
            end
          end
        end
      end
    end
  end
end
