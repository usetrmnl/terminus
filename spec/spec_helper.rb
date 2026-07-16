# frozen_string_literal: true

require "simplecov"

unless ENV["COVERAGE"] == "no"
  SimpleCov.start "strict" do
    group "Actions", "app/actions"
    group "Aspects", "app/aspects"
    group "Config", "config"
    group "Contracts", "app/contracts"
    group "DB", "app/db"
    group "Jobs", "app/jobs"
    group "Lib", "lib"
    group "Models", "app/models"
    group "Providers", "app/providers"
    group "Relations", "app/relations"
    group "Repositories", "app/repositories/"
    group "Schemas", "app/schemas"
    group "Serializers", "app/serializers"
    group "Slices", "slices"
    group "Structs", "app/structs"
    group "Uploaders", "app/uploaders"
    group "Views", "app/views"
    ignore_branches :implicit_else
    skip "app/templates"
    skip "slices/authentication/templates"
  end
end

Bundler.require :tools

require "bcrypt"
require "dry/monads"
require "inspectable/rspec/matchers/match_inspection"
require "refinements"
require "warning"

SPEC_ROOT = Pathname(__dir__).realpath.freeze

POORLY_MAINTAINED_GEMS = /
  http.cookie
/x

using Refinements::Pathname

Pathname.require_tree SPEC_ROOT.join("support/matchers")
Pathname.require_tree SPEC_ROOT.join("support/shared_examples")
Pathname.require_tree SPEC_ROOT.join("support/shared_contexts")

Warning.ignore POORLY_MAINTAINED_GEMS

RSpec.configure do |config|
  config.color = true
  config.disable_monkey_patching!
  config.example_status_persistence_file_path = "./tmp/rspec-examples.txt"
  config.filter_run_when_matching :focus
  config.formatter = ENV.fetch("CI", false) == "true" ? :progress : :documentation
  config.order = :random
  config.pending_failure_output = :no_backtrace
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.warnings = true

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_doubled_constant_names = true
    mocks.verify_partial_doubles = true
  end

  config.before(:suite) { Dry::Monads.load_extensions :rspec }

  Kernel.srand config.seed
end
