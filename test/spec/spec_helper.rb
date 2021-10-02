#require 'simplecov'
#SimpleCov.start

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'

# If an argument is passed, chdir to ../../snakes/<arg>/

if ARGV[0]
  Dir.chdir "/workspaces/starter-snake-ruby/snakes/#{ARGV[0]}/"
  require_relative "../../snakes/#{ARGV[0]}/app/app.rb"
else
  require_relative '../app'
end


include Rack::Test::Methods

def app
  Sinatra::Application
end