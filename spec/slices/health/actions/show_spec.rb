# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Health::Actions::Show do
  subject(:action) { described_class.new }

  describe "#call" do
    it "answers green background on success" do
      expect(action.call({}).body.first).to include(
        %(<main style="background-color: green; height: 100vh;">\n</main>)
      )
    end

    it "answers red background on failure" do
      action = described_class.new.dup

      def action.handle(*) = fail StandardError, "Danger!"

      expect(action.call({}).body.first).to include(
        %(<main style="background-color: red; height: 100vh;">\n</main>)
      )
    end
  end
end
