# frozen_string_literal: true

ENV["HANAMI_ENV"] = "test"

require "capybara/cuprite"
require "capybara/rspec"
require "capybara/validate_html5"
require "database_cleaner/sequel"
require "hanami/cli"
require "hanami/prepare"
require "rack/test"
require "rom-factory"
require "shrine/storage/memory"
require "sidekiq"
require "spec_helper"

using Refinements::Pathname

Factory = ROM::Factory.configure { |config| config.rom = Hanami.app["db.rom"] }
                      .struct_namespace(Terminus::Structs)

ENV["LD_PRELOAD"] = nil
Capybara.app = Hanami.app
Capybara.server = :puma, {Silent: true, Threads: "0:1"}
Capybara.javascript_driver = :cuprite
Capybara.save_path = Hanami.app.root.join "tmp/capybara"
Capybara.register_driver :cuprite do |app|
  browser_options = {"disable-gpu" => nil, "disable-dev-shm-usage" => nil, "no-sandbox" => nil}
  Capybara::Cuprite::Driver.new app, browser_options:, window_size: [1920, 1080]
end

Sidekiq.testing! :inline

Pathname.require_tree SPEC_ROOT.join("support/factories")

RSpec.configure do |config|
  config.include Capybara::DSL, Capybara::RSpecMatchers, type: :feature
  config.include Rack::Test::Methods, type: :request

  config.define_derived_metadata(file_path: %r(/spec/features/)) { it[:type] = :feature }
  config.define_derived_metadata(file_path: %r(/spec/requests/)) { it[:type] = :request }

  config.include_context "with application dependencies", type: :feature
  config.include_context "with application dependencies", type: :request
  config.include_context "with user statuses", type: :feature
  config.include_context "with user statuses", type: :request
  config.include_context "with login", type: :feature

  databases = proc do
    Hanami.app.slices.with_nested.prepend(Hanami.app).each.with_object Set.new do |slice, dbs|
      next unless slice.key? "db.rom"

      dbs.merge slice["db.rom"].gateways.values.map(&:connection).to_enum
    end
  end

  config.before :suite do
    Hanami.app.start :mini_magick
    Hanami.app.start :sidekiq

    databases.call.each do |db|
      DatabaseCleaner[:sequel, db:].clean_with :truncation, except: %w[schema_migrations]
    end
  end

  config.before do
    Hanami.app[:shrine].storages.each_value(&:clear!)
    Sidekiq.redis(&:flushdb)
  end

  config.prepend_before :each, :db do |example|
    databases.call.each do |db|
      DatabaseCleaner[:sequel, db:].strategy = example.metadata[:js] ? :truncation : :transaction
      DatabaseCleaner[:sequel, db:].start
    end
  end

  config.append_after :each, :db do
    databases.call.each { |db| DatabaseCleaner[:sequel, db:].clean }
  end
end
