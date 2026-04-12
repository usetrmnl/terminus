# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::URIBuilder do
  subject(:builder) { described_class.new }

  describe "#call" do
    it "answers URIs with default data" do
      expect(builder.call("https://test.io")).to contain_exactly("https://test.io")
    end

    it "answers URIs with custom data" do
      template = <<~CONTENT
        https://test.io/{{one}}
        https://test.io/{{two}}
      CONTENT

      data = {"one" => 1, "two" => 2}

      expect(builder.call(template, data)).to eq(%w[https://test.io/1 https://test.io/2])
    end
  end
end
