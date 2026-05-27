# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::Importers::Remote::Transforms::Reliquefier do
  subject(:transformer) { described_class.new }

  describe "#call" do
    it "answers updated indexes" do
      template = <<~CONTENT
        {{ IDX_0 }}
        {{ IDX_1 }}
        {{ IDX_2 }}
      CONTENT

      expect(transformer.call(template)).to be_success(<<~CONTENT)
        {{ source_1 }}
        {{ source_2 }}
        {{ source_3 }}
      CONTENT
    end

    it "answers updated keys" do
      template = <<~CONTENT
        {{ data }}
        {{ rss.channel.item[0] }}
        {{ trmnl.plugin_settings.instance_name }}
        {{ trmnl.plugin_settings.custom_fields_values.test }}
        {{ trmnl.plugin_settings.custom_fields[0].name }}
      CONTENT

      expect(transformer.call(template)).to be_success(<<~CONTENT)
        {{ source_1 }}
        {{ source_1.rss.channel.item[0] }}
        {{ extension.label }}
        {{ extension.values.test }}
        {{ extension.fields[0].name }}
      CONTENT
    end

    it "answers updated assigns" do
      template = <<~CONTENT.strip
        {% assign one = trmnl.plugin_settings.custom_fields_values.feed_selection | two: "test" %}
      CONTENT

      expect(transformer.call(template)).to be_success(
        %({% assign one = extension.values.feed_selection | two: "test" %})
      )
    end

    it "answers updated fors" do
      template = <<~CONTENT.strip
        {% for planet in planets %}
          <span>{{ planet.label }}</span>
        {% endfor %}
      CONTENT

      expect(transformer.call(template)).to be_success(template)
    end

    it "answers updated tags" do
      template = %({% render "main", trmnl: trmnl, rss: rss %})

      expect(transformer.call(template)).to be_success(
        %({% render "main", extension: extension, source_1: source_1.rss %})
      )
    end
  end
end
