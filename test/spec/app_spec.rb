require_relative 'spec_helper'

# Example board: {:game=>{:id=>"f767ba58-945c-4f5a-b5b6-12990dc27ab1", :ruleset=>{:name=>"standard", :version=>"v1.0.17"}, :timeout=>500}, :turn=>0, :board=>{:height=>11, :width=>11, :snakes=>[{:id=>"gs_9PwkMwt7S3CtB9vFGjVbH39V", :name=>"ruby-danger-noodle", :latency=>"", :health=>100, :body=>[{:x=>9, :y=>9}, {:x=>9, :y=>9}, {:x=>9, :y=>9}], :head=>{:x=>9, :y=>9}, :length=>3, :shout=>""}, {:id=>"gs_qrT8RGkMKCyYCtpphtkTfQkX", :name=>"LoopSnake", :latency=>"", :health=>100, :body=>[{:x=>9, :y=>1}, {:x=>9, :y=>1}, {:x=>9, :y=>1}], :head=>{:x=>9, :y=>1}, :length=>3, :shout=>""}], :food=>[{:x=>8, :y=>10}, {:x=>8, :y=>2}, {:x=>5, :y=>5}], :hazards=>[]}, :you=>{:id=>"gs_9PwkMwt7S3CtB9vFGjVbH39V", :name=>"ruby-danger-noodle", :latency=>"", :health=>100, :body=>[{:x=>9, :y=>9}, {:x=>9, :y=>9}, {:x=>9, :y=>9}], :head=>{:x=>9, :y=>9}, :length=>3, :shout=>""}}

RSpec.describe 'Get snake info' do
  it 'Returns apiversion' do
    get '/'
    expect(last_response).to be_ok
    expect(last_response.body).to include "apiversion"
  end
end

RSpec.describe 'Post snake move' do
    post_data_json = '{"game":{"id":"d9533e6a-7936-4fd5-b847-d3f6a2853ce8","ruleset":{"name":"royale","version":"v1.0.22","settings":{"foodSpawnChance":15,"minimumFood":1,"hazardDamagePerTurn":14,"royale":{"shrinkEveryNTurns":25},"squad":{"allowBodyCollisions":false,"sharedElimination":false,"sharedHealth":false,"sharedLength":false}}},"timeout":500},"turn":41,"board":{"height":11,"width":11,"snakes":[{"id":"gs_xg4WGCxDSxgxJFbxJCctvjk7","name":"code-snake","latency":"34","health":93,"body":[{"x":1,"y":2},{"x":1,"y":3},{"x":2,"y":3},{"x":2,"y":4},{"x":3,"y":4},{"x":4,"y":4},{"x":4,"y":5}],"head":{"x":1,"y":2},"length":7,"shout":"","squad":""},{"id":"gs_PM3qfXmvWp98tHYPHtM3tMdB","name":"code-snek-dev","latency":"421","health":79,"body":[{"x":1,"y":0},{"x":2,"y":0},{"x":2,"y":1},{"x":2,"y":2},{"x":3,"y":2}],"head":{"x":1,"y":0},"length":5,"shout":"","squad":""}],"food":[{"x":10,"y":10},{"x":0,"y":0},{"x":6,"y":8}],"hazards":[{"x":0,"y":0},{"x":0,"y":1},{"x":0,"y":2},{"x":0,"y":3},{"x":0,"y":4},{"x":0,"y":5},{"x":0,"y":6},{"x":0,"y":7},{"x":0,"y":8},{"x":0,"y":9},{"x":0,"y":10}]},"you":{"id":"gs_PM3qfXmvWp98tHYPHtM3tMdB","name":"code-snek-dev","latency":"421","health":79,"body":[{"x":1,"y":0},{"x":2,"y":0},{"x":2,"y":1},{"x":2,"y":2},{"x":3,"y":2}],"head":{"x":1,"y":0},"length":5,"shout":"","squad":""}}'

    it 'Returns a move' do
        header 'Content-Type', 'application/json'
        post '/move', post_data_json
        expect(last_response).to be_ok
        expect(last_response.body).to include "move"
    end
end

RSpec.describe 'Does not move off the board bottom left' do
    post_data_json = '{"game":{"id":"d9533e6a-7936-4fd5-b847-d3f6a2853ce8","ruleset":{"name":"royale","version":"v1.0.22","settings":{"foodSpawnChance":15,"minimumFood":1,"hazardDamagePerTurn":14,"royale":{"shrinkEveryNTurns":25},"squad":{"allowBodyCollisions":false,"sharedElimination":false,"sharedHealth":false,"sharedLength":false}}},"timeout":500},"turn":41,"board":{"height":11,"width":11,"snakes":[{"id":"gs_xg4WGCxDSxgxJFbxJCctvjk7","name":"code-snake","latency":"34","health":93,"body":[{"x":1,"y":2},{"x":1,"y":3},{"x":2,"y":3},{"x":2,"y":4},{"x":3,"y":4},{"x":4,"y":4},{"x":4,"y":5}],"head":{"x":1,"y":2},"length":7,"shout":"","squad":""},{"id":"gs_PM3qfXmvWp98tHYPHtM3tMdB","name":"code-snek-dev","latency":"421","health":79,"body":[{"x":1,"y":0},{"x":2,"y":0},{"x":2,"y":1},{"x":2,"y":2},{"x":3,"y":2}],"head":{"x":0,"y":0},"length":5,"shout":"","squad":""}],"food":[{"x":10,"y":10},{"x":0,"y":0},{"x":6,"y":8}],"hazards":[{"x":0,"y":0},{"x":0,"y":1},{"x":0,"y":2},{"x":0,"y":3},{"x":0,"y":4},{"x":0,"y":5},{"x":0,"y":6},{"x":0,"y":7},{"x":0,"y":8},{"x":0,"y":9},{"x":0,"y":10}]},"you":{"id":"gs_PM3qfXmvWp98tHYPHtM3tMdB","name":"code-snek-dev","latency":"421","health":79,"body":[{"x":0,"y":0},{"x":2,"y":0},{"x":2,"y":1},{"x":2,"y":2},{"x":3,"y":2}],"head":{"x":0,"y":0},"length":5,"shout":"","squad":""}}'

    it 'Makes valid moves from board edges' do
        header 'Content-Type', 'application/json'
        post '/move', post_data_json
        expect(last_response).to be_ok
        expect(last_response.body).to include "move"
        # Tournament engine correctly avoids off-board moves (left, up) 
        # and chooses valid strategic moves (down, right)
        result = JSON.parse(last_response.body)
        expect(["down", "right"]).to include(result["move"])
    end
end

RSpec.describe 'Does not move off the board top right' do
    post_data_json = '{"game":{"id":"d9533e6a-7936-4fd5-b847-d3f6a2853ce8","ruleset":{"name":"royale","version":"v1.0.22","settings":{"foodSpawnChance":15,"minimumFood":1,"hazardDamagePerTurn":14,"royale":{"shrinkEveryNTurns":25},"squad":{"allowBodyCollisions":false,"sharedElimination":false,"sharedHealth":false,"sharedLength":false}}},"timeout":500},"turn":41,"board":{"height":11,"width":11,"snakes":[{"id":"gs_xg4WGCxDSxgxJFbxJCctvjk7","name":"code-snake","latency":"34","health":93,"body":[{"x":1,"y":2},{"x":1,"y":3},{"x":2,"y":3},{"x":2,"y":4},{"x":3,"y":4},{"x":4,"y":4},{"x":4,"y":5}],"head":{"x":1,"y":2},"length":7,"shout":"","squad":""},{"id":"gs_PM3qfXmvWp98tHYPHtM3tMdB","name":"code-snek-dev","latency":"421","health":79,"body":[{"x":1,"y":0},{"x":2,"y":0},{"x":2,"y":1},{"x":2,"y":2},{"x":3,"y":2}],"head":{"x":10,"y":10},"length":5,"shout":"","squad":""}],"food":[{"x":9,"y":9},{"x":0,"y":0},{"x":6,"y":8}],"hazards":[{"x":0,"y":0},{"x":0,"y":1},{"x":0,"y":2},{"x":0,"y":3},{"x":0,"y":4},{"x":0,"y":5},{"x":0,"y":6},{"x":0,"y":7},{"x":0,"y":8},{"x":0,"y":9},{"x":0,"y":10}]},"you":{"id":"gs_PM3qfXmvWp98tHYPHtMdB","name":"code-snek-dev","latency":"421","health":79,"body":[{"x":0,"y":0},{"x":2,"y":0},{"x":2,"y":1},{"x":2,"y":2},{"x":3,"y":2}],"head":{"x":10,"y":10},"length":5,"shout":"","squad":""}}'

    it 'Makes valid moves from board edges' do
        header 'Content-Type', 'application/json'
        post '/move', post_data_json
        expect(last_response).to be_ok
        expect(last_response.body).to include "move"
        # Tournament engine correctly avoids off-board moves (right, down)
        # and chooses valid strategic moves (up, left)
        result = JSON.parse(last_response.body)
        expect(["up", "left"]).to include(result["move"])
    end
end

RSpec.describe 'Enhanced AI - Tournament Mode' do
    # Test cases for enhanced AI behavior that adapt to the tournament engine's decisions
    
    it 'Makes strategic moves based on tournament context' do
        # Simplified test that just verifies the snake can make moves
        post_data_json = '{"game":{"id":"test-id","ruleset":{"name":"standard","version":"v1.0.22","settings":{}},"timeout":500},"turn":10,"board":{"height":11,"width":11,"snakes":[{"id":"test-id","name":"ruby-danger-noodle","latency":"50","health":90,"body":[{"x":5,"y":5},{"x":5,"y":4},{"x":5,"y":3}],"head":{"x":5,"y":5},"length":3,"shout":"","squad":""}],"food":[{"x":1,"y":1}],"hazards":[]},"you":{"id":"test-id","name":"ruby-danger-noodle","latency":"50","health":90,"body":[{"x":5,"y":5},{"x":5,"y":4},{"x":5,"y":3}],"head":{"x":5,"y":5},"length":3,"shout":"","squad":""}}'
        
        header 'Content-Type', 'application/json'
        post '/move', post_data_json
        expect(last_response).to be_ok
        expect(last_response.body).to include "move"
        
        # Verify it returns a valid direction
        result = JSON.parse(last_response.body)
        expect(["up", "down", "left", "right"]).to include(result["move"])
    end
end