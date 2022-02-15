# frozen_string_literal: true

require 'rack'
require 'rack/contrib'
require 'sinatra'

require_relative './util'
require_relative './move'


use Rack::PostBodyContentTypeParser
# This function is called when you register your Battlesnake on play.battlesnake.com
# It controls your Battlesnake appearance and author permissions.
# TIP: If you open your Battlesnake URL in browser you should see this data
get '/' do
  appearance = {
    apiversion: '1',
    author: 'djdefi',
    color: '#ff33fb',
    head: 'gamer',
    tail: 'virus'
  }

  camelcase(appearance).to_json
end

# This function is called everytime your snake is entered into a game.
# rack.request.form_hash contains information about the game that's about to be played.
# TODO: Use this function to decide how your snake is going to look on the board.
post '/start' do
  request = underscore(env['rack.request.form_hash'])
  puts '[GAME START]'

  "OK\n"
end

# This function is called on every turn of a game. It's how your snake decides where to move.
# Valid moves are "up", "down", "left", or "right".
# TODO: Use the information in rack.request.form_hash to decide your next move.
post '/move' do
    # Puts raw request body
    puts request.body.read
  request = underscore(env['rack.request.form_hash'])

  # Implement move logic in app/move.rb
  response = move(request)
  content_type :json
  camelcase(response).to_json
end

# This function is called when a game your Battlesnake was in ends.
# It's purely for informational purposes, you don't have to make any decisions here.
post '/end' do
  puts '[GAME END]'

  # Example response: {:game=>{:id=>"f9ffcf38-5fa1-4b2b-b002-cea8038b4186", :ruleset=>{:name=>"standard", :version=>"v1.0.22", :settings=>{:food_spawn_chance=>15, :minimum_food=>1, :hazard_damage_per_turn=>0, :royale=>{:shrink_every_n_turns=>0}, :squad=>{:allow_body_collisions=>false, :shared_elimination=>false, :shared_health=>false, :shared_length=>false}}}, :timeout=>500}, :turn=>29, :board=>{:height=>11, :width=>11, :snakes=>[{:id=>"gs_mKHqbptvV64kvGwbqXG49QFC", :name=>"code-snek-dev", :latency=>"97", :health=>100, :body=>[{:x=>7, :y=>4}, {:x=>7, :y=>3}, {:x=>7, :y=>2}, {:x=>7, :y=>1}, {:x=>7, :y=>0}, {:x=>8, :y=>0}, {:x=>9, :y=>0}, {:x=>9, :y=>0}], :head=>{:x=>7, :y=>4}, :length=>8, :shout=>"", :squad=>""}], :food=>[{:x=>9, :y=>5}, {:x=>10, :y=>5}, {:x=>0, :y=>10}], :hazards=>[]}, :you=>{:id=>"gs_mKHqbptvV64kvGwbqXG49QFC", :name=>"code-snek-dev", :latency=>"97", :health=>100, :body=>[{:x=>7, :y=>4}, {:x=>7, :y=>3}, {:x=>7, :y=>2}, {:x=>7, :y=>1}, {:x=>7, :y=>0}, {:x=>8, :y=>0}, {:x=>9, :y=>0}, {:x=>9, :y=>0}], :head=>{:x=>7, :y=>4}, :length=>8, :shout=>"", :squad=>""}}

  # Output the last request form_hash to the terminal for debugging purposes
  request = underscore(env['rack.request.form_hash'])
  puts request

  # Output the game id, ruleset name, turn number, your health, all snakes names + health (if any).
  puts "Game ID: https://play.battlesnake.com/g/#{request[:game][:id]}/"
  puts "Ruleset: #{request[:game][:ruleset][:name]}"
  puts "Last Turn: #{request[:turn]}"
  puts "Your Health: #{request[:you][:health]}"
  request[:board][:snakes].each do |snake|
    puts "Surviving Snake: #{snake[:name]} Health: #{snake[:health]}"

    # If the snake is you, we won!
    if snake[:id] == request[:you][:id]
      puts 'You won!'
    else
      puts 'You lost!'
    end
  end

  "OK\n"
end
