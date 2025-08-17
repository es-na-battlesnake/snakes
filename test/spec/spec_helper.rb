# require 'simplecov'
# SimpleCov.start

ENV['RACK_ENV'] = 'test'

require 'rspec'
require 'rack/test'

# If an argument is passed, chdir to ../../snakes/<arg>/

if ARGV[0]
  #Dir.chdir "/workspaces/starter-snake-ruby/snakes/#{ARGV[0]}/"
  require_relative "../../snakes/ruby/#{ARGV[0]}/app/app.rb"
else
  require_relative '../app'
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
  
  def app
    Sinatra::Application
  end
end
