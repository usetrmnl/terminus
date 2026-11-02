# frozen_string_literal: true

RSpec::Matchers.define :match_shrine_uri do |extension: nil|
  match { |actual| actual.match? %r(memory://\h{32}\.#{extension}) }
end
