# frozen_string_literal: true

RSpec::Matchers.define :match_rfc_3339 do
  match { |actual| actual.match?(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\+|-)\d{2}:\d{2}/) }
end
