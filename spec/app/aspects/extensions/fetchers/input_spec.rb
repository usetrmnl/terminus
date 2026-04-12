# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::Fetchers::Input do
  subject(:request) { described_class.new uri: "https://test.io" }

  describe "#initialize" do
    it "answers default attributes" do
      expect(request).to eq(
        described_class[headers: {},
                        verb: "get",
                        uri: "https://test.io",
                        body: {}]
      )
    end
  end
end
