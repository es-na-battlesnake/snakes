# frozen_string_literal: true
require 'sinatra/reloader'
also_reload './move.rb'

after_reload do
  puts 'reloaded'
end

require './app/app'
run Sinatra::Application
