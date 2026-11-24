# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Views::Scopes::FormField do
  subject(:scope) { described_class.new locals:, rendering: Terminus::View.new.rendering }

  let(:locals) { {key: :label, errors: {label: %w[invalid missing]}} }

  describe "#alpine" do
    it "answers attributes when present" do
      locals[:alpine] = {show: "test === 'test'", on: "test"}
      expect(scope.alpine).to eq(%( x-show="test === 'test'" x-on="test"))
    end

    it "answers nil when missing" do
      expect(scope.alpine).to be(nil)
    end
  end

  describe "#toggle_error" do
    it "answers default kind when errors is nil" do
      locals[:errors] = nil
      expect(scope.toggle_error).to eq("form-field")
    end

    it "answers default kind when errors is empty" do
      locals[:errors].clear
      expect(scope.toggle_error).to eq("form-field")
    end

    it "answers default kind for key with no errors" do
      locals[:key] = :clean
      expect(scope.toggle_error).to eq("form-field")
    end

    it "answers default kind with error class with errors" do
      expect(scope.toggle_error).to eq("form-field error")
    end

    it "answers custom kind with errors" do
      expect(scope.toggle_error("test")).to eq("test error")
    end
  end

  describe "#error_message" do
    it "answers empty string when errors is nil" do
      locals[:errors] = nil
      expect(scope.error_message).to eq("")
    end

    it "answers empty string when given no errors" do
      locals[:errors].clear
      expect(scope.error_message).to eq("")
    end

    it "answers empty string with missing local" do
      scope = described_class.new rendering: Terminus::View.new.rendering
      expect(scope.error_message).to eq("")
    end

    it "answers message when given errors" do
      expect(scope.error_message).to eq("invalid and missing")
    end
  end

  describe "#render" do
    it "renders without errors" do
      locals[:errors].clear
      content = scope.render { "Test" }

      expect(content).to eq(<<~CONTENT)
        <div class="form-field">
          Test
        </div>
      CONTENT
    end

    it "renders with errors" do
      content = scope.render { "Test" }

      expect(content).to eq(<<~CONTENT)
        <div class="form-field error">
          Test
            <em class="message">invalid and missing</em>
        </div>
      CONTENT
    end
  end
end
