require 'rack'
require 'rack/contrib'
require 'sinatra'
require_relative './util'
require_relative './move'

use Rack::PostBodyContentTypeParser

# Disable all protections for battlesnake simulator
configure do
  set :protection, false
  set :bind, '0.0.0.0'
  disable :protection
end

# For Sinatra 4+, explicitly disable host authorization
before do
  env.delete('HTTP_HOST_AUTHORIZATION')
end

# This function is called when you register your Battlesnake on play.battlesnake.com
# It controls your Battlesnake appearance and author permissions.
# TIP: If you open your Battlesnake URL in browser you should see this data
get '/' do
  content_type :json
  begin
    appearance = {
      apiversion: "1",        
      author: "bevns",           # TODO: Your Battlesnake Username
      color: "#134106",     # TODO: Personalize
      head: "smile",      # TODO: Personalize
      tail: "small-rattle",      # TODO: Personalize
    }

    camelcase(appearance).to_json
  rescue => e
    puts "Error in root endpoint: #{e.message}"
    puts e.backtrace
    # Return basic JSON response even if there's an error
    {
      apiversion: "1",
      author: "bevns",
      color: "#134106",
      head: "smile",
      tail: "small-rattle"
    }.to_json
  end
end

# This function is called everytime your snake is entered into a game.
# rack.request.form_hash contains information about the game that's about to be played.
# TODO: Use this function to decide how your snake is going to look on the board.
post '/start' do
  request = underscore(env['rack.request.form_hash'])
  puts "START"
  "OK\n"
end

# This function is called on every turn of a game. It's how your snake decides where to move.
# Valid moves are "up", "down", "left", or "right".
# TODO: Use the information in rack.request.form_hash to decide your next move.
post '/move' do
  request = underscore(env['rack.request.form_hash'])

  # Implement move logic in app/move.rb
  response = move(request)
  content_type :json
  camelcase(response).to_json
end

# This function is called when a game your Battlesnake was in ends.
# It's purely for informational purposes, you don't have to make any decisions here.
post '/end' do
  puts "END"
  "OK\n"
end
