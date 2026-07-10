# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Views::Scopes::PopoverDefaultContent do
  subject(:scope) { described_class.new locals:, rendering: Terminus::View.new.rendering }

  let(:locals) { {name: "test", label: "Test"} }

  describe "#element_id" do
    it "answers ID" do
      expect(scope.element_id).to eq("popover-test")
    end
  end

  describe "#render" do
    it "renders content" do
      content = scope.render { "<p>A body.</p>" }

      expect(content).to eq(<<~CONTENT)
        <dialog id="popover-test" class="bit-popover-content" popover="auto">
          <button type="button" class="close" popovertarget="popover-test" popovertargetaction="hide" aria-label="Close dialog">
            <span aria-hidden=true>&times;</span>
            <span class="screen_reader">Close</span>
          </button>

          <h1 class="label">Test</h1>

          &lt;p&gt;A body.&lt;/p&gt;
        </dialog>
      CONTENT
    end

    it "renders content with custom class" do
      locals[:class] = :test
      content = scope.render { "<p>A body.</p>" }

      expect(content).to include(%(<dialog id="popover-test" class="test"))
    end
  end
end
