# frozen_string_literal: true

require "rspec"
require "webmock/rspec"

WebMock.disable_net_connect!

RSpec.configure do |config|
  config.order = :random
  config.disable_monkey_patching!
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
