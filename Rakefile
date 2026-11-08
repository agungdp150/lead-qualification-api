require_relative "config/application"
require "rspec/core/rake_task"
Rails.application.load_tasks
RSpec::Core::RakeTask.new(:spec)
task test: :spec
task default: :spec
