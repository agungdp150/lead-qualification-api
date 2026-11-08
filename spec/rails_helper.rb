# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"
require_relative "../config/environment"
require "spec_helper"
require "rack/mock"

Dir[File.join(__dir__, "support/**/*.rb")].sort.each { |file| require file }

RSpec.configure do |config|
  config.include LeadScoringHelpers
  config.around do |example|
    original_key = ENV["OPENAI_API_KEY"]
    ENV["OPENAI_API_KEY"] = "test-only-not-a-real-key"
    example.run
  ensure
    original_key ? ENV["OPENAI_API_KEY"] = original_key : ENV.delete("OPENAI_API_KEY")
  end
end
