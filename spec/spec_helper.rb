$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'faker'
require 'timecop'
require 'webmock/rspec'
require 'jruby-druid'
require 'support/helpers'

RSpec.configure do |c|
  c.include Helpers
end
