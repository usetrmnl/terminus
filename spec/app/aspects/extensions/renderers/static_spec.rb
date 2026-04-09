# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::Renderers::Static do
  subject(:renderer) { described_class.new }

  describe "#call" do
    let :extension do
      Factory.structs[
        :extension,
        kind: "static",
        body: {
          "days" => [
            {"label" => "One", "at" => "2025-10-31"},
            {"label" => "Two", "at" => "2026-01-01"}
          ]
        },
        template: <<~BODY
          <h1>{{extension.label}}</h1>
          {% for day in source_1.days %}
            <p>{{day.label}}</p>
          {% endfor %}
        BODY
      ]
    end

    it "renders template" do
      data = {"extension" => {"label" => "Days"}}

      expect(renderer.call(extension, context: data)).to be_success(<<~CONTENT.strip)
        <html><head></head><body><h1>Days</h1>

          <p>One</p>

          <p>Two</p>

        </body></html>
      CONTENT
    end
  end
end
