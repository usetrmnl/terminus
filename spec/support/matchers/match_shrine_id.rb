# frozen_string_literal: true

RSpec::Matchers.define :match_shrine_id do |extension: nil|
  match { |actual| actual.match?(/\h{32}\.?#{extension}/) }
end
