# frozen_string_literal: true

RSpec::Matchers.define :match_device_api_key do
  match { |actual| actual.match?(/[a-z0-9]{30}/i) }
end
