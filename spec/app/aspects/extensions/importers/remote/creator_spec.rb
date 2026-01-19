# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::Importers::Remote::Creator, :db do
  subject(:processor) { described_class.new transformer: }

  let :transformer do
    instance_double Terminus::Aspects::Extensions::Importers::Remote::Transformer
  end

  describe "#call" do
    let :attributes do
      {
        name: "test",
        label: "Test",
        description: "Imported from TRMNL.",
        kind: "poll",
        headers: nil,
        fields: [],
        verb: "get",
        pollers: ["https://test.io/test"],
        interval: 1,
        unit: "minute",
        template: "<h1>Test</h1>"
      }
    end

    it "imports without associated model" do
      allow(transformer).to receive(:call).and_return Success(attributes)
      result = processor.call(1).success.to_h

      expect(result.to_h).to include(name: "test", models: [])
    end

    it "imports with default model" do
      model = Factory[:model, name: "og_plus"]
      allow(transformer).to receive(:call).and_return Success(attributes)
      result = processor.call(1).success

      expect(result.to_h).to include(name: "test", models: [hash_including(id: model.id)])
    end

    it "imports with exchanges" do
      attributes.merge! headers: {accept: "application/json"}, verb: "post", body: {name: "test"}
      allow(transformer).to receive(:call).and_return Success(attributes)
      processor.call(1).success

      data = Terminus::Repositories::ExtensionExchange.new.all.map(&:to_h)

      expect(data).to contain_exactly(
        hash_including(
          headers: {"accept" => "application/json"},
          verb: "post",
          template: "https://test.io/test",
          body: {"name" => "test"}
        )
      )
    end
  end
end
