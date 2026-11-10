# frozen_string_literal: true

require "hanami_helper"

RSpec.describe "Logger", :db do
  include_context "with application dependencies"

  it "logs message without a block" do
    logger.info "A test."
    expect(logger.reread).to match(/INFO.+A test/)
  end

  it "logs message with a block" do
    logger.info { "A test." }
    expect(logger.reread).to match(/INFO.+A test/)
  end
end
