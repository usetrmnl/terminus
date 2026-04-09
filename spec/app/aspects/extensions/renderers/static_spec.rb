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
          {% for day in source.days %}
            <p>{{day.label}}</p>
          {% endfor %}
        BODY
      ]
    end

    it "renders template" do
      context = {"extension" => {"label" => "Days"}}

      expect(renderer.call(extension, context:)).to be_success(
        %(<h1>Days</h1>\n\n  <p>One</p>\n\n  <p>Two</p>\n\n)
      )
    end
  end
end
