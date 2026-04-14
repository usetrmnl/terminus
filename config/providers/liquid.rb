# frozen_string_literal: true

Hanami.app.register_provider :liquid, namespace: true do
  prepare { require "trmnl/liquid" }

  start do
    default = TRMNL::Liquid.new { |environment| environment.error_mode = :strict }

    basic = lambda do |template, data, environment: default|
      Liquid::Template.parse(template, environment:).render(data)
    end

    sanitized = lambda do |template, data, environment: default|
      slice["aspects.sanitizer"].call Liquid::Template.parse(template, environment:).render(data)
    end

    register :basic, basic
    register :default, sanitized
  end
end
