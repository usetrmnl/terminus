# frozen_string_literal: true

require "bundler/setup"
require "git/lint/rake/register"
require "hanami/rake_tasks"
require "open3"
require "reek/rake/task"
require "rspec/core/rake_task"
require "rubocop/rake_task"

Git::Lint::Rake::Register.call
Reek::Rake::Task.new { |task| task.source_files = "{app,config,lib,slices}/**/*.rb" }
RSpec::Core::RakeTask.new { |task| task.verbose = false }
RuboCop::RakeTask.new

Rake.add_rakelib "lib/tasks"

desc "Run Haskell Dockerfile Linter"
task :hadolint do
  puts "Running Haskell Dockerfile Linter..."

  Open3.capture3("hadolint Dockerfile").then do |stdout, _stderr, status|
    status.success? ? puts("✓ No issues detected.") : abort(stdout)
  end
end

desc "Run code quality checks"
task quality: %i[git_lint reek rubocop hadolint]

task default: %i[quality spec]
