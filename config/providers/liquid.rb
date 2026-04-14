# frozen_string_literal: true

Hanami.app.register_provider :liquid, namespace: true do
  prepare { require "trmnl/liquid" }

  start do
    default = TRMNL::Liquid.new { |environment| environment.error_mode = :strict }

    renderer = lambda do |template, data, environment: default|
      slice["aspects.sanitizer"].call Liquid::Template.parse(template, environment:).render(data)
    end

    raw = lambda do |template, data, environment: default|
      Liquid::Template.parse(template, environment:).render(data)
    end

    register :default, renderer
    register :raw, raw
  end
end
