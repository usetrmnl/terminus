# frozen_string_literal: true

require "dry/monads"
require "liquid"

module Terminus
  module Aspects
    module Extensions
      module Importers
        module Remote
          module Transforms
            # A Liquid template transformer.
            class Reliquefier
              include Deps["aspects.extensions.importers.remote.transforms.resolver"]
              include Dry::Monads[:result]

              def initialize(parser: Liquid::Template, **)
                super(**)
                @buffer = +""
                @parser = parser
              end

              def call template
                buffer.clear
                visit parser.parse(template).root
                Success buffer
              end

              private

              attr_reader :buffer, :parser

              # :reek:FeatureEnvy
              # :reek:DuplicateMethodCall
              # :reek:TooManyStatements
              # rubocop:todo Metrics/AbcSize
              # rubocop:todo Metrics/CyclomaticComplexity
              # rubocop:todo Metrics/MethodLength
              def visit node
                case node
                  when String then buffer << node
                  when Liquid::Document, Liquid::BlockBody
                    node.nodelist.each { visit it }
                  when Liquid::Block
                    buffer << "{% #{node.raw.strip} %}"
                    bodies = node.nodelist

                    node.blocks.each.with_index do |block, index|
                      buffer << "{% else %}" if block.else?
                      bodies[index].nodelist.each { visit it }
                    end

                    buffer << "{% #{node.block_delimiter.strip} %}"
                  when Liquid::Assign then reassign(node)
                  when Liquid::Tag then retag(node)
                  when Liquid::Variable then revariable(node)
                  else Failure "Unknown node: #{node.inspect}."
                end
              end
              # rubocop:enable Metrics/AbcSize
              # rubocop:enable Metrics/CyclomaticComplexity
              # rubocop:enable Metrics/MethodLength

              def reassign node
                buffer << "{% assign #{node.to} = #{assignment node.from} %}"
              end

              # :reek:UtilityFunction
              def assignment node
                case node
                  when Liquid::Variable
                    content = node.raw.strip
                    resolver.call(:variables).each { it.call content }
                    content
                  else node
                end
              end

              def retag node
                content = node.raw.strip
                resolver.call(:tags).each { it.call content }

                buffer << "{% #{content} %}"
              end

              def revariable node
                content = node.raw.strip
                resolver.call(:variables).each { it.call content }

                buffer << "{{ #{content} }}"
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
