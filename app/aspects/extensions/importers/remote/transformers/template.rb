# frozen_string_literal: true

require "initable"
require "refinements/hash"

module Terminus
  module Aspects
    module Extensions
      module Importers
        module Remote
          module Transformers
            # Transforms (mutates) the full Liquid template for initialization.
            class Template
              include Deps[keyer: "aspects.extensions.importers.remote.transformers.template_keys"]
              include Initable[
                layout: <<~BODY
                  <div class="{{extension.css_classes}}">
                    <div class="view view--full">
                      %<content>s
                    </div>
                  </div>
                BODY
              ]

              using Refinements::Hash

              def call attributes, archive
                merge_content(archive).then { keyer.call it }
                                      .fmap { attributes.merge! template: it }
              end

              private

              def merge_content archive
                archive.use do |shared, full|
                  full_transform = format layout, content: full
                  [shared, full_transform].compact.join "\n\n"
                end
              end
            end
          end
        end
      end
    end
  end
end
