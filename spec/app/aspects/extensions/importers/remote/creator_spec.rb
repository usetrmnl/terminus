# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::Importers::Remote::Creator, :db do
  subject(:creator) { described_class.new transformer: }

  let :transformer do
    instance_double Terminus::Aspects::Extensions::Importers::Remote::Transformer
  end

  include_context "with application dependencies"

  describe "#call" do
    let :attributes do
      {
        name: "test",
        label: "Test",
        description: "Imported from TRMNL.",
        kind: "poll",
        poll_headers: nil,
        fields: [],
        poll_verb: "get",
        poll_template: ["https://test.io/test"],
        interval: 1,
        unit: "minute",
        template: "<h1>Test</h1>"
      }
    end

    it "imports without associated model" do
      allow(transformer).to receive(:call).and_return Success(attributes)
      result = creator.call(1).success.to_h

      expect(result.to_h).to include(name: "test", models: [])
    end

    it "imports with default model" do
      model = Factory[:model, name: "og_plus"]
      allow(transformer).to receive(:call).and_return Success(attributes)
      result = creator.call(1).success

      expect(result.to_h).to include(name: "test", models: [hash_including(id: model.id)])
    end

    it "imports with exchanges" do
      attributes.merge! poll_headers: {accept: "application/json"},
                        poll_verb: "post",
                        poll_body: {name: "test"}
      allow(transformer).to receive(:call).and_return Success(attributes)
      creator.call 1

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

    context "when exchange template can't be transformned" do
      subject(:creator) { described_class.new(transformer:, reliquefier:) }

      let :reliquefier do
        instance_double(
          Terminus::Aspects::Extensions::Importers::Remote::Transforms::Reliquefier,
          call: Failure("Danger!")
        )
      end

      before { allow(transformer).to receive(:call).and_return Success(attributes) }

      it "uses empty string for template" do
        creator.call 1
        data = Terminus::Repositories::ExtensionExchange.new.all.map(&:to_h)

        expect(data).to contain_exactly(hash_including(template: ""))
      end

      it "logs debug message" do
        creator.call 1
        expect(logger.reread).to match(/DEBUG.+Danger!/)
      end

      it "logs error with unknown result" do
        allow(reliquefier).to receive(:call).and_return "Danger!"
        creator.call 1

        expect(logger.reread).to match(/ERROR.+Unable to transform/)
      end
    end

    it "fails with duplicate import" do
      Factory[:extension, name: "test"]
      allow(transformer).to receive(:call).and_return Success(attributes)

      expect(creator.call(1)).to be_failure(
        %(Name must be unique. Please use a value other than "test".)
      )
    end
  end
end
