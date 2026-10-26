# frozen_string_literal: true

require "hanami/prepare"
require "refinements/pathname"

using Refinements::Pathname

output = Pathname("tmp").join("browser").make_dir.clear

render = lambda do |index = 1|
  name = index.to_s.rjust 3, "0"

  Hanami.app["aspects.screens.shoter"]
        .call "<h1>Test: #{name}</h1>", output.join("#{name}.png"), width: 200, height: 100
end

puts "Render 1: #{render.call.success? ? "success" : "failure"}"

# rubocop:todo-next Style/SendWithLiteralMethodName
# rubocop:todo-next Style/Send
pid = Hanami.app["aspects.browser"].send(:client).process.pid
Process.kill "KILL", pid # Simulates the Chromium browser process crashing.
sleep 1

results = (2..601).map { render.call it }

puts "Renders 2-601: #{results.count(&:success?)} succeeded, #{results.count(&:failure?)} failed"
puts "Last failure: #{results.last.failure}" if results.last.failure?
