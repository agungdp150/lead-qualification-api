ENV["RAILS_ENV"] ||= "production"
require_relative "../config/environment"
require_relative "../lib/vercel_adapter"

Handler = proc { |request, response| VercelAdapter.call(Rails.application, request, response) }
