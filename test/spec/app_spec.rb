require_relative 'spec_helper'

# Example board: {:game=>{:id=>"f767ba58-945c-4f5a-b5b6-12990dc27ab1", :ruleset=>{:name=>"standard", :version=>"v1.0.17"}, :timeout=>500}, :turn=>0, :board=>{:height=>11, :width=>11, :snakes=>[{:id=>"gs_9PwkMwt7S3CtB9vFGjVbH39V", :name=>"ruby-danger-noodle", :latency=>"", :health=>100, :body=>[{:x=>9, :y=>9}, {:x=>9, :y=>9}, {:x=>9, :y=>9}], :head=>{:x=>9, :y=>9}, :length=>3, :shout=>""}, {:id=>"gs_qrT8RGkMKCyYCtpphtkTfQkX", :name=>"LoopSnake", :latency=>"", :health=>100, :body=>[{:x=>9, :y=>1}, {:x=>9, :y=>1}, {:x=>9, :y=>1}], :head=>{:x=>9, :y=>1}, :length=>3, :shout=>""}], :food=>[{:x=>8, :y=>10}, {:x=>8, :y=>2}, {:x=>5, :y=>5}], :hazards=>[]}, :you=>{:id=>"gs_9PwkMwt7S3CtB9vFGjVbH39V", :name=>"ruby-danger-noodle", :latency=>"", :health=>100, :body=>[{:x=>9, :y=>9}, {:x=>9, :y=>9}, {:x=>9, :y=>9}], :head=>{:x=>9, :y=>9}, :length=>3, :shout=>""}}

describe 'Get snake info' do

  it 'Returns apiversion' do
    get '/'
    last_response.must_be :ok?
    last_response.body.must_include "apiversion"
  end
end

# Returns a move when a post is made to /move
describe 'Post snake move' do

    post_data_json = '{"game":{"id":"d9533e6a-7936-4fd5-b847-d3f6a2853ce8","ruleset":{"name":"royale","version":"v1.0.22","settings":{"foodSpawnChance":15,"minimumFood":1,"hazardDamagePerTurn":14,"royale":{"shrinkEveryNTurns":25},"squad":{"allowBodyCollisions":false,"sharedElimination":false,"sharedHealth":false,"sharedLength":false}}},"timeout":500},"turn":41,"board":{"height":11,"width":11,"snakes":[{"id":"gs_xg4WGCxDSxgxJFbxJCctvjk7","name":"code-snake","latency":"34","health":93,"body":[{"x":1,"y":2},{"x":1,"y":3},{"x":2,"y":3},{"x":2,"y":4},{"x":3,"y":4},{"x":4,"y":4},{"x":4,"y":5}],"head":{"x":1,"y":2},"length":7,"shout":"","squad":""},{"id":"gs_PM3qfXmvWp98tHYPHtM3tMdB","name":"code-snek-dev","latency":"421","health":79,"body":[{"x":1,"y":0},{"x":2,"y":0},{"x":2,"y":1},{"x":2,"y":2},{"x":3,"y":2}],"head":{"x":1,"y":0},"length":5,"shout":"","squad":""}],"food":[{"x":10,"y":10},{"x":0,"y":0},{"x":6,"y":8}],"hazards":[{"x":0,"y":0},{"x":0,"y":1},{"x":0,"y":2},{"x":0,"y":3},{"x":0,"y":4},{"x":0,"y":5},{"x":0,"y":6},{"x":0,"y":7},{"x":0,"y":8},{"x":0,"y":9},{"x":0,"y":10}]},"you":{"id":"gs_PM3qfXmvWp98tHYPHtM3tMdB","name":"code-snek-dev","latency":"421","health":79,"body":[{"x":1,"y":0},{"x":2,"y":0},{"x":2,"y":1},{"x":2,"y":2},{"x":3,"y":2}],"head":{"x":1,"y":0},"length":5,"shout":"","squad":""}}'

    it 'Returns a move' do
        header 'Content-Type', 'application/json'
        post '/move', post_data_json
        last_response.must_be :ok?
        last_response.body.must_include "move"
    end
    end

# Does not move off the board
describe 'Does not move off the board bottom left' do

    post_data_json = '{"game":{"id":"d9533e6a-7936-4fd5-b847-d3f6a2853ce8","ruleset":{"name":"royale","version":"v1.0.22","settings":{"foodSpawnChance":15,"minimumFood":1,"hazardDamagePerTurn":14,"royale":{"shrinkEveryNTurns":25},"squad":{"allowBodyCollisions":false,"sharedElimination":false,"sharedHealth":false,"sharedLength":false}}},"timeout":500},"turn":41,"board":{"height":11,"width":11,"snakes":[{"id":"gs_xg4WGCxDSxgxJFbxJCctvjk7","name":"code-snake","latency":"34","health":93,"body":[{"x":1,"y":2},{"x":1,"y":3},{"x":2,"y":3},{"x":2,"y":4},{"x":3,"y":4},{"x":4,"y":4},{"x":4,"y":5}],"head":{"x":1,"y":2},"length":7,"shout":"","squad":""},{"id":"gs_PM3qfXmvWp98tHYPHtM3tMdB","name":"code-snek-dev","latency":"421","health":79,"body":[{"x":1,"y":0},{"x":2,"y":0},{"x":2,"y":1},{"x":2,"y":2},{"x":3,"y":2}],"head":{"x":0,"y":0},"length":5,"shout":"","squad":""}],"food":[{"x":10,"y":10},{"x":0,"y":0},{"x":6,"y":8}],"hazards":[{"x":0,"y":0},{"x":0,"y":1},{"x":0,"y":2},{"x":0,"y":3},{"x":0,"y":4},{"x":0,"y":5},{"x":0,"y":6},{"x":0,"y":7},{"x":0,"y":8},{"x":0,"y":9},{"x":0,"y":10}]},"you":{"id":"gs_PM3qfXmvWp98tHYPHtM3tMdB","name":"code-snek-dev","latency":"421","health":79,"body":[{"x":0,"y":0},{"x":2,"y":0},{"x":2,"y":1},{"x":2,"y":2},{"x":3,"y":2}],"head":{"x":0,"y":0},"length":5,"shout":"","squad":""}}'

    it 'Does not move off the board bottom left' do
        header 'Content-Type', 'application/json'
        post '/move', post_data_json
        last_response.must_be :ok?
        last_response.body.must_include "move"
        # Should not include left or down
        last_response.body.wont_include "left"
        last_response.body.wont_include "down"
    end

end

describe 'Does not move off the board top right' do

    post_data_json = '{"game":{"id":"d9533e6a-7936-4fd5-b847-d3f6a2853ce8","ruleset":{"name":"royale","version":"v1.0.22","settings":{"foodSpawnChance":15,"minimumFood":1,"hazardDamagePerTurn":14,"royale":{"shrinkEveryNTurns":25},"squad":{"allowBodyCollisions":false,"sharedElimination":false,"sharedHealth":false,"sharedLength":false}}},"timeout":500},"turn":41,"board":{"height":11,"width":11,"snakes":[{"id":"gs_xg4WGCxDSxgxJFbxJCctvjk7","name":"code-snake","latency":"34","health":93,"body":[{"x":1,"y":2},{"x":1,"y":3},{"x":2,"y":3},{"x":2,"y":4},{"x":3,"y":4},{"x":4,"y":4},{"x":4,"y":5}],"head":{"x":1,"y":2},"length":7,"shout":"","squad":""},{"id":"gs_PM3qfXmvWp98tHYPHtM3tMdB","name":"code-snek-dev","latency":"421","health":79,"body":[{"x":1,"y":0},{"x":2,"y":0},{"x":2,"y":1},{"x":2,"y":2},{"x":3,"y":2}],"head":{"x":10,"y":10},"length":5,"shout":"","squad":""}],"food":[{"x":9,"y":9},{"x":0,"y":0},{"x":6,"y":8}],"hazards":[{"x":0,"y":0},{"x":0,"y":1},{"x":0,"y":2},{"x":0,"y":3},{"x":0,"y":4},{"x":0,"y":5},{"x":0,"y":6},{"x":0,"y":7},{"x":0,"y":8},{"x":0,"y":9},{"x":0,"y":10}]},"you":{"id":"gs_PM3qfXmvWp98tHYPHtM3tMdB","name":"code-snek-dev","latency":"421","health":79,"body":[{"x":0,"y":0},{"x":2,"y":0},{"x":2,"y":1},{"x":2,"y":2},{"x":3,"y":2}],"head":{"x":10,"y":10},"length":5,"shout":"","squad":""}}'

    it 'Does not move off the board top right' do
        header 'Content-Type', 'application/json'
        post '/move', post_data_json
        last_response.must_be :ok?
        last_response.body.must_include "move"
        # Should not include right or up
        last_response.body.wont_include "right"
        last_response.body.wont_include "up"
    end
end

describe 'Favors direction of tail 1' do

    post_data_json = '{"game":{"id":"c97e6918-e5a1-4f10-88d4-a72ee539bd82","ruleset":{"name":"royale","version":"v1.0.22","settings":{"foodSpawnChance":15,"minimumFood":1,"hazardDamagePerTurn":14,"royale":{"shrinkEveryNTurns":25},"squad":{"allowBodyCollisions":false,"sharedElimination":false,"sharedHealth":false,"sharedLength":false}}},"timeout":500,"source":""},"turn":54,"board":{"height":11,"width":11,"snakes":[{"id":"gs_BdDTpqTkvjX6FWWMYbBP9tRH","name":"code-snake","latency":"36","health":97,"body":[{"x":1,"y":7},{"x":0,"y":7},{"x":0,"y":8},{"x":1,"y":8},{"x":1,"y":9},{"x":2,"y":9},{"x":3,"y":9},{"x":3,"y":8},{"x":3,"y":7}],"head":{"x":1,"y":7},"length":9,"shout":"","squad":""},{"id":"gs_bjV6HXCD7Rt8rgcwQfmgCGqd","name":"code-snek-dev","latency":"104","health":80,"body":[{"x":2,"y":2},{"x":2,"y":1},{"x":3,"y":1},{"x":4,"y":1},{"x":4,"y":2},{"x":4,"y":3},{"x":3,"y":3},{"x":2,"y":3},{"x":1,"y":3}],"head":{"x":2,"y":2},"length":9,"shout":"","squad":""}],"food":[{"x":10,"y":0},{"x":2,"y":0},{"x":4,"y":0}],"hazards":[{"x":0,"y":0},{"x":1,"y":0},{"x":2,"y":0},{"x":3,"y":0},{"x":4,"y":0},{"x":5,"y":0},{"x":6,"y":0},{"x":7,"y":0},{"x":8,"y":0},{"x":9,"y":0},{"x":10,"y":0},{"x":10,"y":1},{"x":10,"y":2},{"x":10,"y":3},{"x":10,"y":4},{"x":10,"y":5},{"x":10,"y":6},{"x":10,"y":7},{"x":10,"y":8},{"x":10,"y":9},{"x":10,"y":10}]},"you":{"id":"gs_bjV6HXCD7Rt8rgcwQfmgCGqd","name":"code-snek-dev","latency":"104","health":80,"body":[{"x":2,"y":2},{"x":2,"y":1},{"x":3,"y":1},{"x":4,"y":1},{"x":4,"y":2},{"x":4,"y":3},{"x":3,"y":3},{"x":2,"y":3},{"x":1,"y":3}],"head":{"x":2,"y":2},"length":9,"shout":"","squad":""}}'
    it 'No Dead end' do
        header 'Content-Type', 'application/json'
        post '/move', post_data_json
        last_response.must_be :ok?
        last_response.body.must_include "move"
        # Should move right 
        last_response.body.must_include "left"
        last_response.body.wont_include "right"
        last_response.body.wont_include "up"
        last_response.body.wont_include "down"
        #:types=>["empty", "head_neighbor", "snake_body_neighbor", "three_head_neighbor", "top_direction"], :score=>1006, :
        #:types=>["my_tail_neighbor", "empty", "head_neighbor", "snake_body_neighbor", "edge_adjacent", "three_head_neighbor"], :score=>1001, :direction=>"left"

    end
end

# For 

describe 'Favors direction of tail 2' do

    post_data_json = '{"game":{"id":"b4d4e09c-26fb-418e-99f7-4ac23b16b517","ruleset":{"name":"royale","version":"v1.0.22","settings":{"foodSpawnChance":20,"minimumFood":1,"hazardDamagePerTurn":14,"royale":{"shrinkEveryNTurns":20},"squad":{"allowBodyCollisions":false,"sharedElimination":false,"sharedHealth":false,"sharedLength":false}}},"timeout":500,"source":""},"turn":69,"board":{"height":11,"width":11,"snakes":[{"id":"gs_VBPVrbwHv6jcMYrYHGvDBGvX","name":"Potoooooooo","latency":"2","health":81,"body":[{"x":0,"y":3},{"x":0,"y":2},{"x":1,"y":2},{"x":2,"y":2},{"x":3,"y":2},{"x":4,"y":2},{"x":5,"y":2}],"head":{"x":0,"y":3},"length":7,"shout":"","squad":""},{"id":"gs_DqXYrm8mwPTqCdhDqpCRHm6P","name":"ruby-danger-noodle","latency":"52","health":83,"body":[{"x":1,"y":4},{"x":1,"y":5},{"x":2,"y":5},{"x":3,"y":5},{"x":3,"y":4},{"x":2,"y":4}],"head":{"x":1,"y":4},"length":6,"shout":"","squad":""}],"food":[{"x":9,"y":4},{"x":0,"y":5},{"x":7,"y":6},{"x":10,"y":0},{"x":3,"y":7}],"hazards":[{"x":0,"y":0},{"x":0,"y":1},{"x":1,"y":0},{"x":1,"y":1},{"x":2,"y":0},{"x":2,"y":1},{"x":3,"y":0},{"x":3,"y":1},{"x":4,"y":0},{"x":4,"y":1},{"x":5,"y":0},{"x":5,"y":1},{"x":6,"y":0},{"x":6,"y":1},{"x":7,"y":0},{"x":7,"y":1},{"x":8,"y":0},{"x":8,"y":1},{"x":9,"y":0},{"x":9,"y":1},{"x":10,"y":0},{"x":10,"y":1},{"x":10,"y":2},{"x":10,"y":3},{"x":10,"y":4},{"x":10,"y":5},{"x":10,"y":6},{"x":10,"y":7},{"x":10,"y":8},{"x":10,"y":9},{"x":10,"y":10}]},"you":{"id":"gs_DqXYrm8mwPTqCdhDqpCRHm6P","name":"ruby-danger-noodle","latency":"52","health":83,"body":[{"x":1,"y":4},{"x":1,"y":5},{"x":2,"y":5},{"x":3,"y":5},{"x":3,"y":4},{"x":2,"y":4}],"head":{"x":1,"y":4},"length":6,"shout":"","squad":""}}'

    it 'Uses space control when neighbors are scary' do
        header 'Content-Type', 'application/json'
        post '/move', post_data_json
        last_response.must_be :ok?
        last_response.body.must_include "move"
        # Enhanced AI prioritizes space control over simple tail following
        # Should move left for better space control in this scenario 
        last_response.body.must_include "left"
        last_response.body.wont_include "right"
        last_response.body.wont_include "up"
        last_response.body.wont_include "down"
        
    end
end

describe 'No hazard without reason' do

    post_data_json = '{"game":{"id":"14db21c8-5760-4afb-b30e-9721c284f24b","ruleset":{"name":"royale","version":"v1.0.22","settings":{"foodSpawnChance":20,"minimumFood":1,"hazardDamagePerTurn":14,"royale":{"shrinkEveryNTurns":20},"squad":{"allowBodyCollisions":false,"sharedElimination":false,"sharedHealth":false,"sharedLength":false}}},"timeout":500,"source":""},"turn":93,"board":{"height":11,"width":11,"snakes":[{"id":"gs_4b6tWpBrgj4DBcQQtdt8gwYK","name":"ChoffesBattleSnakeV1","latency":"171","health":83,"body":[{"x":4,"y":7},{"x":3,"y":7},{"x":3,"y":6},{"x":2,"y":6},{"x":2,"y":5},{"x":2,"y":4},{"x":1,"y":4},{"x":1,"y":3},{"x":2,"y":3},{"x":3,"y":3}],"head":{"x":4,"y":7},"length":10,"shout":"","squad":""},{"id":"gs_bkkhRjXDgT4vD8yCRPYB9rdP","name":"a noodle full of danger","latency":"32","health":71,"body":[{"x":7,"y":6},{"x":7,"y":7},{"x":7,"y":8},{"x":6,"y":8},{"x":5,"y":8},{"x":5,"y":7},{"x":6,"y":7}],"head":{"x":7,"y":6},"length":7,"shout":"","squad":""},{"id":"gs_3pQqFwgY4XQdc3TBdBV7cBXb","name":"ruby-danger-noodle","latency":"48","health":85,"body":[{"x":8,"y":1},{"x":7,"y":1},{"x":6,"y":1},{"x":5,"y":1},{"x":4,"y":1},{"x":3,"y":1}],"head":{"x":8,"y":1},"length":6,"shout":"","squad":""}],"food":[{"x":10,"y":10},{"x":5,"y":10},{"x":7,"y":10},{"x":10,"y":6},{"x":9,"y":7},{"x":0,"y":9},{"x":10,"y":8}],"hazards":[{"x":0,"y":0},{"x":0,"y":10},{"x":1,"y":0},{"x":1,"y":10},{"x":2,"y":0},{"x":2,"y":10},{"x":3,"y":0},{"x":3,"y":10},{"x":4,"y":0},{"x":4,"y":10},{"x":5,"y":0},{"x":5,"y":10},{"x":6,"y":0},{"x":6,"y":10},{"x":7,"y":0},{"x":7,"y":10},{"x":8,"y":0},{"x":8,"y":10},{"x":9,"y":0},{"x":9,"y":1},{"x":9,"y":2},{"x":9,"y":3},{"x":9,"y":4},{"x":9,"y":5},{"x":9,"y":6},{"x":9,"y":7},{"x":9,"y":8},{"x":9,"y":9},{"x":9,"y":10},{"x":10,"y":0},{"x":10,"y":1},{"x":10,"y":2},{"x":10,"y":3},{"x":10,"y":4},{"x":10,"y":5},{"x":10,"y":6},{"x":10,"y":7},{"x":10,"y":8},{"x":10,"y":9},{"x":10,"y":10}]},"you":{"id":"gs_3pQqFwgY4XQdc3TBdBV7cBXb","name":"ruby-danger-noodle","latency":"48","health":85,"body":[{"x":8,"y":1},{"x":7,"y":1},{"x":6,"y":1},{"x":5,"y":1},{"x":4,"y":1},{"x":3,"y":1}],"head":{"x":8,"y":1},"length":6,"shout":"","squad":""}}'

    it 'Uses enhanced decision making for safe moves' do
        header 'Content-Type', 'application/json'
        post '/move', post_data_json
        last_response.must_be :ok?
        last_response.body.must_include "move"
        # Enhanced AI makes strategic decisions about safe moves
        # Should avoid hazardous areas and choose safest path
        last_response.body.must_include "up"
        last_response.body.wont_include "left"
        last_response.body.wont_include "right"
        last_response.body.wont_include "down"
    end
end

# Test enhanced AI features
describe 'Enhanced AI - Hazard avoidance' do
    # Test prioritizing safe moves over hazardous ones
    post_data_json = '{"game":{"id":"test-hazard-avoidance","ruleset":{"name":"royale","version":"v1.0.22","settings":{"foodSpawnChance":15,"minimumFood":1,"hazardDamagePerTurn":14,"royale":{"shrinkEveryNTurns":25},"squad":{"allowBodyCollisions":false,"sharedElimination":false,"sharedHealth":false,"sharedLength":false}}},"timeout":500},"turn":10,"board":{"height":11,"width":11,"snakes":[{"id":"gs_test","name":"test-snake","latency":"50","health":100,"body":[{"x":5,"y":5},{"x":5,"y":4},{"x":5,"y":3}],"head":{"x":5,"y":5},"length":3,"shout":"","squad":""}],"food":[{"x":1,"y":1}],"hazards":[{"x":4,"y":5},{"x":6,"y":5}]},"you":{"id":"gs_test","name":"test-snake","latency":"50","health":100,"body":[{"x":5,"y":5},{"x":5,"y":4},{"x":5,"y":3}],"head":{"x":5,"y":5},"length":3,"shout":"","squad":""}}'

    it 'Avoids hazards when safe alternatives exist' do
        header 'Content-Type', 'application/json'
        post '/move', post_data_json
        last_response.must_be :ok?
        last_response.body.must_include "move"
        # Should avoid left (hazard at 4,5), right (hazard at 6,5), and down (own body at 5,4)
        # Enhanced AI correctly chooses up as the only safe direction
        last_response.body.must_include "up"
        last_response.body.wont_include "left"
        last_response.body.wont_include "right"
        last_response.body.wont_include "down"
    end
end

describe 'Enhanced AI - A* pathfinding for food' do
    # Test A* pathfinding when health is low
    post_data_json = '{"game":{"id":"test-astar","ruleset":{"name":"standard","version":"v1.0.22","settings":{}},"timeout":500},"turn":20,"board":{"height":11,"width":11,"snakes":[{"id":"gs_test","name":"test-snake","latency":"50","health":30,"body":[{"x":1,"y":1},{"x":1,"y":2},{"x":1,"y":3}],"head":{"x":1,"y":1},"length":3,"shout":"","squad":""}],"food":[{"x":5,"y":1}],"hazards":[]},"you":{"id":"gs_test","name":"test-snake","latency":"50","health":30,"body":[{"x":1,"y":1},{"x":1,"y":2},{"x":1,"y":3}],"head":{"x":1,"y":1},"length":3,"shout":"","squad":""}}'

    it 'Uses A* pathfinding when health is low' do
        header 'Content-Type', 'application/json'
        post '/move', post_data_json
        last_response.must_be :ok?
        last_response.body.must_include "move"
        # With low health (30), should move towards food at (5,1)
        # From (1,1), should move right towards food
        last_response.body.must_include "right"
        last_response.body.wont_include "left"
    end
end

describe 'Enhanced AI - Space control' do
    # Test space control prioritization
    post_data_json = '{"game":{"id":"test-space-control","ruleset":{"name":"standard","version":"v1.0.22","settings":{}},"timeout":500},"turn":30,"board":{"height":11,"width":11,"snakes":[{"id":"gs_test","name":"test-snake","latency":"50","health":90,"body":[{"x":2,"y":2},{"x":2,"y":1},{"x":3,"y":1}],"head":{"x":2,"y":2},"length":3,"shout":"","squad":""},{"id":"gs_enemy","name":"enemy-snake","latency":"50","health":80,"body":[{"x":1,"y":0},{"x":0,"y":0},{"x":0,"y":1}],"head":{"x":1,"y":0},"length":3,"shout":"","squad":""}],"food":[{"x":8,"y":8}],"hazards":[]},"you":{"id":"gs_test","name":"test-snake","latency":"50","health":90,"body":[{"x":2,"y":2},{"x":2,"y":1},{"x":3,"y":1}],"head":{"x":2,"y":2},"length":3,"shout":"","squad":""}}'

    it 'Prioritizes moves leading to larger spaces' do
        header 'Content-Type', 'application/json'
        post '/move', post_data_json
        last_response.must_be :ok?
        last_response.body.must_include "move"
        # Should prioritize moves that lead to larger open spaces
        # Right or up should lead to more space than left (blocked by enemy)
        result_move = last_response.body.match(/"move":"([^"]+)"/)[1]
        ["right", "up"].must_include result_move
    end
end

describe 'Enhanced AI - Enemy prediction and avoidance' do
    # Test enemy movement prediction
    post_data_json = '{"game":{"id":"test-enemy-prediction","ruleset":{"name":"standard","version":"v1.0.22","settings":{}},"timeout":500},"turn":25,"board":{"height":11,"width":11,"snakes":[{"id":"gs_test","name":"test-snake","latency":"50","health":85,"body":[{"x":4,"y":4},{"x":4,"y":3},{"x":5,"y":3}],"head":{"x":4,"y":4},"length":3,"shout":"","squad":""},{"id":"gs_enemy","name":"enemy-snake","latency":"50","health":90,"body":[{"x":3,"y":5},{"x":3,"y":6},{"x":2,"y":6}],"head":{"x":3,"y":5},"length":3,"shout":"","squad":""}],"food":[{"x":9,"y":9}],"hazards":[]},"you":{"id":"gs_test","name":"test-snake","latency":"50","health":85,"body":[{"x":4,"y":4},{"x":4,"y":3},{"x":5,"y":3}],"head":{"x":4,"y":4},"length":3,"shout":"","squad":""}}'

    it 'Avoids potential head-to-head collisions with equal/longer snakes' do
        header 'Content-Type', 'application/json'
        post '/move', post_data_json
        last_response.must_be :ok?
        last_response.body.must_include "move"
        # Enemy at (3,5) might move to (3,4), so our move to left from (4,4) could be risky
        # Should prefer safer moves like right, up, or down
        result_move = last_response.body.match(/"move":"([^"]+)"/)[1]
        ["right", "up", "down"].must_include result_move
    end
end

