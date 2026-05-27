# frozen_string_literal: true

require "dry/monads"
require "initable"
require "liquid"

module Terminus
  module Aspects
    module Extensions
      module Importers
        module Remote
          module Transformers
            # A Liquid template formatter.
            class Retemplate
              include Initable[parser: Liquid::Template]
              include Dry::Monads[:result]

              def call template, buffer
                template = parser.parse template
                visit template.root, buffer
              end

              private

              # :reek:FeatureEnvy
              # :reek:DuplicateMethodCall
              # :reek:TooManyStatements
              # rubocop:todo Metrics/AbcSize
              # rubocop:todo Metrics/CyclomaticComplexity
              # rubocop:todo Metrics/MethodLength
              def visit node, buffer
                case node
                  when String then buffer << node
                  when Liquid::Document, Liquid::BlockBody
                    node.nodelist.each { visit it, buffer }
                  when Liquid::Block
                    buffer << "{% #{node.raw.strip} %}"
                    bodies = node.nodelist

                    node.blocks.each.with_index do |block, index|
                      buffer << "{% else %}" if block.else?
                      bodies[index].nodelist.each { visit it, buffer }
                    end

                    buffer << "{% #{node.block_delimiter.strip} %}"
                  when Liquid::Assign
                    buffer << "{% assign #{node.to} = #{assignment node.from} %}"
                  when Liquid::Tag
                    buffer << node.raw
                  when Liquid::Variable then buffer << "{{ #{node.raw.strip} }}"
                  else Falure "Unknown node: #{node.inspect}."
                end
              end
              # rubocop:enable Metrics/AbcSize
              # rubocop:enable Metrics/CyclomaticComplexity
              # rubocop:enable Metrics/MethodLength

              # :reek:UtilityFunction
              def assignment node
                case node
                  when Liquid::Variable then node.raw.strip
                  else node
                end
              end
            end
          end
        end
      end
    end
  end
end

# TODO: Remove when finished.
__END__

if block.left
  binding.break pre: "info"
  buffer << "{% elsif #{block.left.name} #{block.operator} #{block.right} %}"
  block.attachment.nodelist.each { visit it, buffer }
else
  buffer << "{% else %}"
  block.attachment.nodelist.each { visit it, buffer }
end
