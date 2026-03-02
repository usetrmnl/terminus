# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::Importers::Remote::Transformers::URIs do
  subject(:transformer) { described_class.new }

  describe "#call" do
    let(:attributes) { {uris: "https://test.io/test.json"} }

    it "answers success for single URI" do
      expect(transformer.call(attributes)).to be_success(uris: ["https://test.io/test.json"])
    end

    it "answers success with multiple URIs for new lines, carriage returns, and spaces" do
      attributes[:uris] = "https://one.io\n" \
                          "https://two.io\r" \
                          "https://three.io\r\n" \
                          "https://four.io " \
                          "https://five.io"

      expect(transformer.call(attributes)).to be_success(
        uris: %w[https://one.io https://two.io https://three.io https://four.io https://five.io]
      )
    end

    it "answers failure with Liquid syntax (single line)" do
      attributes[:uris] = "https://{{domain}}/test.json"

      expect(transformer.call(attributes)).to be_failure(
        "URLs with Liquid syntax isn't supported at the moment."
      )
    end

    it "answers failure with Liquid syntax (multiple lines)" do
      attributes[:uris] = <<~CONTENT
        https://{{
          domain
        }}/test.json
      CONTENT

      expect(transformer.call(attributes)).to be_failure(
        "URLs with Liquid syntax isn't supported at the moment."
      )
    end
  end
end
