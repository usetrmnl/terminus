# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Screens::Upserters::Unprocessed, :db do
  using Refinements::Struct

  subject(:upserter) { described_class.new }

  include_context "with screen mold"

  describe "#call" do
    let(:model) { Factory[:model] }

    it "answers screen" do
      mold.with! model_id: model.id,
                 content: "https://raw.githubusercontent.com/usetrmnl/terminus/main/spec" \
                          "/support/fixtures/test.png"

      result = upserter.call mold

      expect(result.success).to have_attributes(
        model_id: model.id,
        name: "test",
        label: "Test",
        image_attributes: hash_including(
          metadata: hash_including(
            size: kind_of(Integer),
            width: 800,
            height: 480,
            filename: "test.png",
            mime_type: "image/png"
          )
        )
      )
    end
  end
end
