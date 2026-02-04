# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::Importers::Remote::Transformers::Kind do
  subject(:transformer) { described_class.new }

  describe "#call" do
    let :attributes do
      {body: %({"sort":"name"}), static_data: %({"email": "test@test.io"})}
    end

    it "answers success when polling" do
      attributes[:strategy] = "polling"
      expect(transformer.call(attributes)).to be_success(kind: "poll", body: %({"sort":"name"}))
    end

    it "answers success when static" do
      attributes[:strategy] = "static"

      expect(transformer.call(attributes)).to be_success(
        kind: "static",
        body: %({"email": "test@test.io"})
      )
    end

    it "answers success when webhook" do
      attributes[:strategy] = "webhook"
      expect(transformer.call(attributes)).to be_success(kind: "webhook", body: %({"sort":"name"}))
    end

    it "answers failure with unknown kind" do
      attributes = {strategy: "bogus"}

      expect(transformer.call(attributes)).to be_failure(
        "Unsupported kind: bogus. Use: polling, static, or webhook."
      )
    end
  end
end
