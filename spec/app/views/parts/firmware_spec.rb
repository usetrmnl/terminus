# frozen_string_literal: true

require "hanami_helper"

# rubocop:todo-next RSpec/EmptyExampleGroup
RSpec.describe Terminus::Views::Parts::Firmware do
  subject(:part) { described_class.new value: firmware, rendering: Terminus::View.new.rendering }

  let(:firmware) { Factory.structs[:firmware] }
end
