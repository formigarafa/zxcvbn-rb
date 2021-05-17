# frozen_string_literal: true

require "bundler/setup"
require "pry-byebug"

Dir[Pathname.new(File.expand_path(__dir__)).join("support/**/*.rb")].sort.each { |f| require f }

RSpec.configure do |config|
  config.include JsHelpers
  config.include ResultHelpers
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

if ENV["DISABLE_COVERAGE"] != "true"
  require "simplecov"
  SimpleCov.start
end
require "zxcvbn"
