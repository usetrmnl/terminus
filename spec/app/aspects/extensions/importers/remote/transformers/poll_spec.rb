# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::Importers::Remote::Transformers::Poll do
  subject(:transformer) { described_class.new }

  describe "#call" do
    let(:attributes) { {poll_template: "https://test.io/test.json"} }

    it "answers success for single URI" do
      expect(transformer.call(attributes)).to be_success(poll_template: ["https://test.io/test.json"])
    end

    it "answers success URI is nil" do
      attributes[:poll_template] = nil
      expect(transformer.call(attributes)).to be_success(poll_template: [])
    end

    it "answers success with multiple URIs for new lines, carriage returns, and spaces" do
      attributes[:poll_template] = "https://one.io\n" \
                                   "https://two.io\r" \
                                   "https://three.io\r\n" \
                                   "https://four.io " \
                                   "https://five.io"

      expect(transformer.call(attributes)).to be_success(
        poll_template: %w[https://one.io https://two.io https://three.io https://four.io https://five.io]
      )
    end

    it "answers success with Liquid syntax (single line)" do
      attributes[:poll_template] = "https://{{domain}}/test.json"
      expect(transformer.call(attributes)).to be_success(poll_template: ["https://{{domain}}/test.json"])
    end

    it "answers success with Liquid syntax (multiple lines)" do
      attributes[:poll_template] = <<~CONTENT
        https://{{
          domain
        }}/test.json
      CONTENT

      expect(transformer.call(attributes)).to be_success(
        poll_template: [<<~CONTENT]
          https://{{
            domain
          }}/test.json
        CONTENT
      )
    end
  end
end
