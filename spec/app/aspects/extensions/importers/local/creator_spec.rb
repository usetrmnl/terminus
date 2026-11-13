# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::Importers::Local::Creator, :db do
  subject(:creator) { described_class.new }

  describe "#call" do
    let :io do
      manifest = {"configuration.yml" => configuration, "template.html.liquid" => "<h1>Test</h1>"}
      Terminus::Aspects::Zipper.new.call(manifest).value!
    end

    let :configuration do
      <<~CONTENT
        version: 1.2.3
        name: test
        label: Test
        description: "A test."
        mode: text
        kind: poll
        tags: [test]
        static_body:
          a: 1
        fields:
          - name: one
            label: One
        data:
          a: 1
        interval: 1
        unit: minute
        days: []
        last_day_of_month: false
        start_at: '2025-01-01T00:00:00+00:00'
        exchanges:
          - headers:
              content_type: application/json
            verb: get
            body:
              sort: desc
            template: https://test.io
      CONTENT
    end

    it "creates extension" do
      relation = Hanami.app["relations.extension"]
      expectation = proc { creator.call io }
      count = proc { relation.count }

      expect(&expectation).to change(&count).by(1)
    end

    it "creates exchanges" do
      relation = Hanami.app["relations.extension_exchange"]
      expectation = proc { creator.call io }
      count = proc { relation.count }

      expect(&expectation).to change(&count).by(1)
    end

    it "answers success" do
      expect(creator.call(io)).to match(Success(kind_of(Terminus::Structs::Extension)))
    end

    context "with out exchanges" do
      let :configuration do
        <<~CONTENT
          version: 1.2.3
          name: test
          label: Test
          description:
          mode: text
          kind: poll
          tags: []
          static_body:
          fields:
          data:
          interval: 1
          unit: minute
          days: []
          last_day_of_month: false
          start_at: '2025-01-01T00:00:00+00:00'
          exchanges: []
        CONTENT
      end

      it "answers success when there are no exchanges" do
        expect(creator.call(io)).to match(Success(kind_of(Terminus::Structs::Extension)))
      end
    end

    context "with empty exchanges" do
      let :configuration do
        <<~CONTENT
          version: 1.2.3
          name: test
          label: Test
          description:
          mode: text
          kind: poll
          tags: []
          static_body:
          fields:
          data:
          interval: 1
          unit: minute
          days: []
          last_day_of_month: false
          start_at: '2025-01-01T00:00:00+00:00'
          exchanges: []
        CONTENT
      end

      it "answers success" do
        expect(creator.call(io)).to match(Success(kind_of(Terminus::Structs::Extension)))
      end
    end

    context "with invalid exchanges" do
      let :configuration do
        <<~CONTENT
          version: 1.2.3
          name: test
          label: Test
          description:
          mode: text
          kind: poll
          tags: []
          static_body:
          fields:
          data:
          interval: 1
          unit: minute
          days: []
          last_day_of_month: false
          start_at: '2025-01-01T00:00:00+00:00'
          exchanges:
            - headers:
              verb: get
              template:
              body:
        CONTENT
      end

      it "answers failure" do
        expect(creator.call(io)).to be_failure("Import exchanges.0.template must be filled.")
      end
    end

    it "answers failure with invalid zip file structure" do
      io = Terminus::Aspects::Zipper.new.call(Hash.new).value!
      expect(creator.call(io)).to match(Failure(/version is missing/))
    end

    it "answers failure when extension can't be created" do
      extension_creator = instance_double(
        Terminus::Aspects::Extensions::Importers::Local::Creators::Extension,
        call: Failure("Danger!")
      )

      creator = described_class.new(extension_creator:)

      expect(creator.call(io)).to be_failure("Danger!")
    end

    it "answers failure when exchange can't be created" do
      exchange_creator = instance_double(
        Terminus::Aspects::Extensions::Importers::Local::Creators::Exchange,
        call: Failure("Danger!")
      )

      creator = described_class.new(exchange_creator:)

      expect(creator.call(io)).to be_failure("Danger!")
    end
  end
end
