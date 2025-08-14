# frozen_string_literal: true

require 'set'

$VERBOSE = nil
$stdout.sync = true

# A* pathfinding to find the safest path to food
def a_star_to_food(board_state)
  return nil if board_state[:food].empty?
  
  closest_food = board_state[:food].min_by { |f| manhattan_distance(board_state[:head], f) }
  path = a_star_pathfind(board_state[:head], closest_food, board_state)
  
  return nil if path.nil? || path.length < 2
  
  # Return the direction to the next step in the path
  next_step = path[1]
  direction_between(board_state[:head][:x], board_state[:head][:y], next_step[:x], next_step[:y])
end

# Manhattan distance between two points
def manhattan_distance(point1, point2)
  (point1[:x] - point2[:x]).abs + (point1[:y] - point2[:y]).abs
end

# A* pathfinding algorithm
def a_star_pathfind(start, goal, board_state)
  open_set = [start]
  came_from = {}
  g_score = { start => 0 }
  f_score = { start => manhattan_distance(start, goal) }
  
  while !open_set.empty?
    current = open_set.min_by { |node| f_score[node] || Float::INFINITY }
    
    return reconstruct_path(came_from, current) if current == goal
    
    open_set.delete(current)
    
    neighbors = get_safe_neighbors(current, board_state)
    neighbors.each do |neighbor|
      tentative_g_score = g_score[current] + 1
      
      if tentative_g_score < (g_score[neighbor] || Float::INFINITY)
        came_from[neighbor] = current
        g_score[neighbor] = tentative_g_score
        f_score[neighbor] = tentative_g_score + manhattan_distance(neighbor, goal)
        
        open_set << neighbor unless open_set.include?(neighbor)
      end
    end
  end
  
  nil # No path found
end

# Get safe neighbors for pathfinding
def get_safe_neighbors(cell, board_state)
  adjacent_cells(cell[:x], cell[:y]).select do |neighbor|
    !is_wall_for_board?(neighbor[:x], neighbor[:y], board_state) &&
    !is_occupied_for_board?(neighbor[:x], neighbor[:y], board_state) &&
    !is_dangerous_for_board?(neighbor[:x], neighbor[:y], board_state)
  end
end

# Check if a cell is occupied by any snake
def is_occupied_for_board?(x, y, board_state)
  board_state[:all_occupied_cells].any? do |cell| 
    cell.is_a?(Hash) && cell[:x].to_i == x.to_i && cell[:y].to_i == y.to_i
  end
end

# Check if a cell is dangerous (near enemy snake heads or hazards)
def is_dangerous_for_board?(x, y, board_state)
  # Check if it's a hazard
  return true if board_state[:hazards].any? { |h| h[:x].to_i == x.to_i && h[:y].to_i == y.to_i }
  
  # Check if it's adjacent to a longer or equal length enemy snake head
  board_state[:snakes_heads_not_my_head].each do |enemy_head|
    enemy_snake = board_state[:snakes].find { |s| s[:head] == enemy_head }
    next unless enemy_snake
    
    if enemy_snake[:length] >= board_state[:length] && manhattan_distance({x: x, y: y}, enemy_head) <= 1
      return true
    end
  end
  
  false
end

# Check if a cell is a wall for pathfinding
def is_wall_for_board?(x, y, board_state)
  game_mode = board_state[:game_mode]
  width = board_state[:width]
  height = board_state[:height]
  
  if game_mode == 'wrapped'
    false
  else
    x.negative? || y.negative? || x >= width || y >= height
  end
end

# Reconstruct path from A* algorithm
def reconstruct_path(came_from, current)
  path = [current]
  while came_from[current]
    current = came_from[current]
    path.unshift(current)
  end
  path
end

# Flood fill to avoid dead ends
def flood_fill_from(start_pos, board_state)
  visited = Set.new
  queue = [start_pos]
  visited.add(start_pos)
  
  while !queue.empty?
    current = queue.shift
    
    adjacent_cells(current[:x], current[:y]).each do |neighbor|
      next if visited.include?(neighbor)
      next if is_wall_for_board?(neighbor[:x], neighbor[:y], board_state)
      next if is_occupied_for_board?(neighbor[:x], neighbor[:y], board_state)
      
      visited.add(neighbor)
      queue << neighbor
    end
  end
  
  visited.size
end

# Get the move direction that leads to the largest space
def get_space_control_move(board_state)
  best_move = nil
  largest_space = 0
  
  board_state[:head_neighbors].each do |neighbor|
    next if is_wall_for_board?(neighbor[:x], neighbor[:y], board_state)
    next if is_occupied_for_board?(neighbor[:x], neighbor[:y], board_state)
    
    space_size = flood_fill_from(neighbor, board_state)
    
    if space_size > largest_space
      largest_space = space_size
      best_move = direction_between(board_state[:head][:x], board_state[:head][:y], neighbor[:x], neighbor[:y])
    end
  end
  
  { move: best_move, space_size: largest_space }
end

# Predict where enemy snakes will move
def predict_enemy_moves(board_state)
  enemy_predictions = {}
  
  board_state[:snakes_heads_not_my_head].each do |enemy_head|
    enemy_snake = board_state[:snakes].find { |s| s[:head] == enemy_head }
    next unless enemy_snake
    
    # Simple prediction: enemy will move towards food or away from walls
    safe_moves = adjacent_cells(enemy_head[:x], enemy_head[:y]).select do |move|
      !is_wall_for_board?(move[:x], move[:y], board_state) && !is_occupied_for_board?(move[:x], move[:y], board_state)
    end
    
    if !safe_moves.empty?
      # Predict they'll move towards nearest food if hungry, otherwise away from walls
      if enemy_snake[:health] < 50 && !board_state[:food].empty?
        nearest_food = board_state[:food].min_by { |f| manhattan_distance(enemy_head, f) }
        predicted_move = safe_moves.min_by { |move| manhattan_distance(move, nearest_food) }
      else
        # Move towards center of board or largest space
        predicted_move = safe_moves.max_by { |move| 
          flood_fill_from(move, board_state)
        }
      end
      
      enemy_predictions[enemy_snake[:id]] = predicted_move
    end
  end
  
  enemy_predictions
end

# This function is called on every turn of a game. It's how your Battlesnake decides where to move.
# Valid moves are "up", "down", "left", or "right".
# TODO: Use the information in board to decide your next move.
def move(board)
  # Record the start time of the turn
  start_time = Time.now

  # Health find threshold variable clamped to 0-100
  @health_threshold = 99
  @health_threshold.clamp(0, 100)

  #puts board

  # Example board object:
  # {:game=>{:id=>"f767ba58-945c-4f5a-b5b6-12990dc27ab1", :ruleset=>{:name=>"standard", :version=>"v1.0.17"}, :timeout=>500}, :turn=>0, :board=>{:height=>11, :width=>11, :snakes=>[{:id=>"gs_9PwkMwt7S3CtB9vFGjVbH39V", :name=>"ruby-danger-noodle", :latency=>"", :health=>100, :body=>[{:x=>9, :y=>9}, {:x=>9, :y=>9}, {:x=>9, :y=>9}], :head=>{:x=>9, :y=>9}, :length=>3, :shout=>""}, {:id=>"gs_qrT8RGkMKCyYCtpphtkTfQkX", :name=>"LoopSnake", :latency=>"", :health=>100, :body=>[{:x=>9, :y=>1}, {:x=>9, :y=>1}, {:x=>9, :y=>1}], :head=>{:x=>9, :y=>1}, :length=>3, :shout=>""}], :food=>[{:x=>8, :y=>10}, {:x=>8, :y=>2}, {:x=>5, :y=>5}], :hazards=>[]}, :you=>{:id=>"gs_9PwkMwt7S3CtB9vFGjVbH39V", :name=>"ruby-danger-noodle", :latency=>"", :health=>100, :body=>[{:x=>9, :y=>9}, {:x=>9, :y=>9}, {:x=>9, :y=>9}], :head=>{:x=>9, :y=>9}, :length=>3, :shout=>""}}

  # Puts board height and width
  @height = board[:board][:height].to_i
  @width = board[:board][:width].to_i

  # Puts all the snakes in an array
  @snakes = board[:board][:snakes] || []
  # puts "There are the following snakes: #{@snakes}"

  # Puts all the food in an array
  @food = board[:board][:food] || []
   #puts "There is food at: #{@food}"

  # Our health
  @health = board[:you][:health].to_i

  # Puts all the hazards in an array
  @hazards = board[:board][:hazards] || []
  # puts "There are hazards at: #{@hazards}"

  # Puts the snakes length
  @length = board[:you][:length].to_i
  # puts "My length is: #{@length}"

  # Puts the ruleset name
  @game_mode = board[:game][:ruleset][:name]

  # Puts the tail cells of all the snakes
  @snake_tails = []
  @snakes.each do |snake|
    @snake_tails << snake[:body][-1]
  end

  # My tail coordinates
  @my_tail = [{:x => board[:you][:body][-1][:x], :y => board[:you][:body][-1][:y]}]
  #puts "My tail is: #{@my_tail}"

  # Puts x, y coordinates hash of all cells on the board
  @board_hash = board[:board][:height].to_i.times.map do |i|
    board[:board][:width].to_i.times.map do |j|
      { x: j, y: i }
    end
  end.flatten

  # Puts x, y coordinates hash of my snake's head
  @head = board[:you][:head]
  # Set @head x and y to_i
  @head[:x] = @head[:x].to_i
  @head[:y] = @head[:y].to_i

  # Puts x, y coordinates hash of my snake's body
  @body = board[:you][:body].map { |b| { x: b[:x], y: b[:y] } }.flatten

  # Puts where all other snakes bodies and heads are
  @snakes_bodies = board[:board][:snakes].map { |s| s[:body] }.flatten + @body || []

  # Puts where all snakes heads are
  @snakes_heads = board[:board][:snakes].map { |s| s[:head] }.flatten || []

  # Puts where all snakes heads are, but not my head
  @snakes_heads_not_my_head = board[:board][:snakes].map { |s| s[:head] }.flatten - [@head] || []
  # Remove my head from the snakes heads
  @snakes_heads_not_my_head.delete(@head)  

  # Puts where all snakes bodies are, but not my body
  @snakes_bodies_not_my_body = board[:board][:snakes].map { |s| s[:body] }.flatten - @body || []
  # Remove my body from the snakes bodies
  @snakes_bodies_not_my_body.delete(@body)

  # Puts where all food cells which are also hazard cells
  @food_hazards = @food.select do |f|
    @hazards.any? do |h|
      f[:x] == h[:x] && f[:y] == h[:y]
    end
  end

  # Function to determine x,y coordinate pair hash of each cell adjacent to the head
  def adjacent_cells(x, y)
    # Set x and y coordinates to_i
    x = x.to_i
    y = y.to_i
    [{ x: x - 1, y: y }, { x: x + 1, y: y }, { x: x, y: y - 1 }, { x: x, y: y + 1 }]
  end

  # Function to determine x,y coordinate pair hash of each cell adjacent to the head within 3 cells
  def adjacent_cells_3(x, y)
    # Set x and y coordinates to_i
    x = x.to_i
    y = y.to_i
    [{ x: x - 1, y: y }, { x: x + 1, y: y }, { x: x, y: y - 1 }, { x: x, y: y + 1 }, { x: x - 1, y: y - 1 }, { x: x - 1, y: y + 1 }, { x: x + 1, y: y - 1 }, { x: x + 1, y: y + 1 }]
  end

  # Food adjacent cells
  @food_adjacent_cells = @food.map { |f| adjacent_cells(f[:x], f[:y]) }.flatten

  @head_neighbors = adjacent_cells(@head[:x], @head[:y])

  @three_head_neighbors = adjacent_cells_3(@head[:x], @head[:y])

  @other_snakes_head_neighbors = @snakes_heads_not_my_head.map { |s| adjacent_cells(s[:x], s[:y]) }.flatten

  # Shared neighbors are cells which are in both @head_neighbors and @other_snakes_head_neighbors
  @shared_neighbors = @head_neighbors.select { |h| @other_snakes_head_neighbors.include?(h) }
  #puts "Shared neighbors are: #{@shared_neighbors}"

  # Id, Name, total Lengths, Coordinates of all snakes heads
  @snakes_info = board[:board][:snakes].map do |s|
    { id: s[:id], name: s[:name], length: s[:body].length, head: s[:head],
      head_neighbors: adjacent_cells(s[:head][:x], s[:head][:y]) }
  end

  # My snake id
  @id = board[:you][:id]

  # Puts where all heads of shorter snakes are
  @shorter_snake_heads = board[:board][:snakes].map { |s| s[:head] }.flatten.select do |h|
    @snakes.any? do |s|
      s[:length] < @length && h[:x] == s[:head][:x] && h[:y] == s[:head][:y]
    end
  end


  # @shared_longer_snakes are cells which are in both @head_neighbors and @other_snakes_head_neighbors and where the length of the neighboring snake is longer than my snake
  @shared_longer_snakes = @shared_neighbors.select do |s|
    @snakes.any? do |s|
      s[:length] > @length && s[:head][:x] == s[:head][:x] && s[:head][:y] == s[:head][:y]
    end
  end

  # @shared_shorter_snakes are cells which are in both @head_neighbors and @other_snakes_head_neighbors and where the length of the neighboring snake is shorter than my snake
  @shared_shorter_snakes = @shared_neighbors.select do |s|
    @snakes.any? do |s|
      s[:length] < @length && s[:head][:x] == s[:head][:x] && s[:head][:y] == s[:head][:y]
    end
  end

  # @shared_same_length_snakes are cells which are in both @head_neighbors and @other_snakes_head_neighbors and where the length of the neighboring snake is the same as my snake
  @shared_same_length_snakes = @shared_neighbors.select do |s|
    @snakes.any? do |s|
      s[:length] == @length && s[:head][:x] == s[:head][:x] && s[:head][:y] == s[:head][:y]
    end
  end

  # Each time the snake eats a piece of food, its tail grows longer, making the game increasingly difficult.
  # The user controls the direction of the snake's head (up, down, left, or right), and the snake's body follows. The player cannot stop the snake from moving while the game is in progress.
  # The board is a 2-dimensional array of cells, each cell containing a hash with x and y coordinates. The board is of variable size, and is surronded by walls.
  # Other snakes and hazards are present on the board and should be avoided.
  # The board is updated every turn.

  @my_snake = @snakes.select { |s| s[:id] == board[:you][:id] }

  # Function to check if a cell is a wall
  def is_wall?(x, y)
    # If game mode is wrapped, set false, else perform wall check
    if @game_mode == 'wrapped'
      false
    else
      if x.negative? || y.negative? || x >= @width || y >= @height
        true
      else
        false
      end
    end
  end

  # Function to check if a cell is a snake body
  def is_snake?(x, y)
    @snakes_bodies.select { |c| c[:x] == x && c[:y] == y }.empty? && @snakes_heads.select do |c|
      c[:x] == x && c[:y] == y
    end.empty? && @body.select do |c|
                    c[:x] == x && c[:y] == y
                  end.empty?
  end

  @all_occupied_cells = (@snakes_heads + @snakes_bodies + @head.to_a + @body).flatten

  # x, y coordinates hash of all empty cells on the board
  @empty_cells = @board_hash - @all_occupied_cells + @food

  # x, y coordinates of each corner cell
  @corners = [{ x: 0, y: 0 }, { x: @width - 1, y: 0 }, { x: 0, y: @height - 1 },
              { x: @width - 1, y: @height - 1 }]

  # x, y coordinates array of every cell around the edge of the board
  @edges = @width.times.map { |x| [{ x: x, y: 0 }, { x: x, y: @height - 1 }] }.flatten + @height.times.map do |y| [{ x: 0, y: y }, { x: @width - 1, y: y }] end.flatten

  # x, y coordinates array of every cell adjacent to cells on the edge of the board
  @edge_adjacent_cells = @edges.each_with_object([]) do |e, a|
    a << adjacent_cells(e[:x], e[:y])
  end.flatten

  # x, y coordinates array of every cell adjacent to hazard cells
  @hazard_adjacent_cells = @hazards.each_with_object([]) do |h, a|
    a << adjacent_cells(h[:x], h[:y])
  end.flatten

  # Cells within 1 cell of any snake body
  @snakes_bodies_neighbors = @snakes_bodies.map { |s| adjacent_cells(s[:x], s[:y]) }.flatten


  # Function to determine the direction between two cell x,y coordinates from the perspective of the snake
  def direction_between(x1, y1, x2, y2)
    # Set values to_i
    x1 = x1.to_i
    y1 = y1.to_i
    x2 = x2.to_i
    y2 = y2.to_i
    if x1 < x2
      'right'
    elsif x1 > x2
      'left'
    elsif y1 < y2
      'up'
    elsif y1 > y2
      'down'
    end
  end

  # Function to determine the two possible directions between two cell x,y coordinates from the perspective of the snake (x1, y1)
  def possible_directions_between(x1, y1, x2, y2)
    # Set values to_i
    x1 = x1.to_i
    y1 = y1.to_i
    x2 = x2.to_i
    y2 = y2.to_i
    if x1 < x2
      if y1 < y2
        %w[right up]
      elsif y1 > y2
        %w[right down]
      end
    elsif x1 > x2
      if y1 < y2
        %w[left down]
      elsif y1 > y2
        %w[left up]
      end
    end
  end

  # Function to determine the opposite direction between two cell x,y coordinates from the perspective of the snake
  def opposite_direction(x1, y1, x2, y2)
    # Set values to_i
    x1 = x1.to_i
    y1 = y1.to_i
    x2 = x2.to_i
    y2 = y2.to_i
    if x1 < x2
      'left'
    elsif x1 > x2
      'right'
    elsif y1 < y2
      'down'
    elsif y1 > y2
      'up'
    end
  end

  # Invert directions
  def invert_direction(direction)
    case direction
    when 'up'
      'down'
    when 'down'
      'up'
    when 'left'
      'right'
    when 'right'
      'left'
    end
  end


  # Given an x,y coordinate on the edge of the board, return the x,y coordinates of the cell on the opposite side of the board
  def opposite_edge_cell(x, y)
    # Set values to_i
    x = x.to_i
    y = y.to_i
    if x == 0
      { x: @width - 1, y: y }
    elsif x == @width - 1
      { x: 0, y: y }
    elsif y == 0
      { x: x, y: @height - 1 }
    elsif y == @height - 1
      { x: x, y: 0 }
    end
  end

  # Function to find the neighbors of a given cell x,y coordinates
  def neighbors_of(x, y)
    adjacent_cells(x, y)
  end

  # My tail neighbors are the cells adjacent to my tail
  @my_tail_neighbors = adjacent_cells(@my_tail.first[:x], @my_tail.first[:y])

  # Cell base score
  @cell_base_score = 1000

  # Dynamic scoring based on game state
  longest_enemy = @snakes.reject { |s| s[:id] == @id }.max_by { |s| s[:length] }&.dig(:length) || 0
  winning_by = @length - longest_enemy
  
  # If we're winning by a lot, be more conservative
  if winning_by >= 3
    @score_multiplier['edge'] = -8
    @score_multiplier['corner'] = -5
    @score_multiplier['food'] = 5  # Less aggressive about food
    @score_multiplier['my_tail_neighbor'] = 25  # More tail following
    puts "Playing conservatively - winning by #{winning_by}"
  elsif winning_by <= -2
    # If we're losing, be more aggressive
    @score_multiplier['food'] = 30
    @score_multiplier['shared_shorter_snake'] = 15
    @score_multiplier['edge'] = -2
    puts "Playing aggressively - losing by #{-winning_by}"
  end
  if @game_mode == 'wrapped'
    #puts '@@@ Using wrapped game mode score multiplier'
    @score_multiplier = {
      'wall' => 0,
      'hazard' => -550,
      'hazard_adjacent' => 0,
      'food' => 55,
      'food_hazard' => 0,
      'food_adjacent' => 20,
      'shared_neighbor' => 0,
      'shared_shorter_snake' => 45,
      'shared_longer_snake' => -80,
      'shared_same_length_snake' => -75,
      'empty' => 55,
      'snake_head' => -2,
      'snake_body' => -2,
      'snake_body_neighbor' => -20,
      'corner' => -1,
      'other_snake_head' => -2,
      'other_snake_body' => -30,
      'other_snake_head_neighbor' => -0,
      'body' => -100,
      'head' => -4,
      'tail' => 2,
      'my_tail' => 6,
      'my_tail_neighbor' => 20,
      'edge' => 0,
      'edge_adjacent' => 0,
      'head_neighbor' => 0,
      'three_head_neighbor' => -2,
      'shorter_snake_heads' => 4
    }
  else
    # Set score multiplier for each type of cell
    @score_multiplier = {
      'wall' => -5,
      'hazard' => -15,
      'hazard_adjacent' => -7,
      'food' => 15,
      'food_hazard' => 2,
      'food_adjacent' => 2,
      'shared_neighbor' => 0,
      'shared_shorter_snake' => 5,
      'shared_longer_snake' => -50,
      'shared_same_length_snake' => -5,
      'empty' => 8,
      'snake_head' => -2,
      'snake_body' => -2,
      'snake_body_neighbor' => -10,
      'corner' => -1,
      'other_snake_head' => -2,
      'other_snake_body' => -130,
      'other_snake_head_neighbor' => -0,
      'body' => -5,
      'head' => -4,
      'tail' => 2,
      'my_tail' => 76,
      'my_tail_neighbor' => 12,
      'edge' => -4,
      'edge_adjacent' => -1,
      'head_neighbor' => 0,
      'three_head_neighbor' => -2,
      'shorter_snake_heads' => 0
    }
  end

  # Create an array of all of this turn's cells. Each cell is a hash with x and y coordinates, a set of types, and the direction of the cell realative to the snake's head.
  # A cell may have multiple types, such as a wall, a hazard, a food, a food_hazard, a shared_neighbor, a snake body, or a snake head.
  # The direction is the direction of the cell relative to the snake's head.

  @turn_score_array = []
  @board_hash.each do |cell|
    # Check what types this cell's x and y coordinates are
    types = []

    # Check if the cell is a wall
    types << 'wall' if is_wall?(cell[:x], cell[:y])
    types << 'corner' if @corners.select { |c| c[:x] == cell[:x] && c[:y] == cell[:y] }.any?
    types << 'other_snake_head' if @snakes_heads.select { |c| c[:x] == cell[:x] && c[:y] == cell[:y] }.any?
    types << 'other_snake_body' if @snakes_bodies.select { |c| c[:x] == cell[:x] && c[:y] == cell[:y] }.any?
    types << 'body' if @body.select { |c| c[:x] == cell[:x] && c[:y] == cell[:y] }.any?
    types << 'tail' if @snake_tails.select { |c| c[:x] == cell[:x] && c[:y] == cell[:y] }.any?
    types << 'my_tail' if @my_tail.select { |c| c[:x] == cell[:x] && c[:y] == cell[:y] }.any?
    types << 'my_tail_neighbor' if @my_tail_neighbors.select { |c| c[:x] == cell[:x] && c[:y] == cell[:y] }.any?
    # types << 'head' if @head.select { |c| c[:x] == cell[:x] && c[:y] == cell[:y] }.any?
    types << 'food' if @food.select { |c| c[:x] == cell[:x] && c[:y] == cell[:y] }.any?
    types << 'food_hazard' if @food_hazards.select { |c| c[:x] == cell[:x] && c[:y] == cell[:y] }.any?
    types << 'hazard' if @hazards.select { |c| c[:x] == cell[:x] && c[:y] == cell[:y] }.any?
    types << 'shared_neighbor' if @shared_neighbors.select { |c| c[:x] == cell[:x] && c[:y] == cell[:y] }.any?
    types << 'shared_shorter_snake' if @shared_shorter_snakes.select { |c| c[:x] == cell[:x] && c[:y] == cell[:y] }.any?
    types << 'shared_longer_snake' if @shared_longer_snakes.select { |c| c[:x] == cell[:x] && c[:y] == cell[:y] }.any?
    types << 'shared_same_length_snake' if @shared_same_length_snakes.select do |c|
                                             c[:x] == cell[:x] && c[:y] == cell[:y]
                                           end.any?
    types << 'empty' if @empty_cells.select { |c| c[:x] == cell[:x] && c[:y] == cell[:y] }.any?
    types << 'head_neighbor' if @head_neighbors.select { |c| c[:x] == cell[:x] && c[:y] == cell[:y] }.any?
    types << 'edge' if @edges.select { |c| c[:x] == cell[:x] && c[:y] == cell[:y] }.any?
    types << 'other_snake_head_neighbor' if @other_snakes_head_neighbors.select do |c| c[:x] == cell[:x] && c[:y] == cell[:y] end.any?
    types << 'snake_body_neighbor' if @snakes_bodies_neighbors.select { |c| c[:x] == cell[:x] && c[:y] == cell[:y] }.any?
    types << 'food_adjacent' if @food_adjacent_cells.select { |c| c[:x] == cell[:x] && c[:y] == cell[:y] }.any?
    types << 'hazard_adjacent' if @hazard_adjacent_cells.select { |c| c[:x] == cell[:x] && c[:y] == cell[:y] }.any?
    types << 'edge_adjacent' if @edge_adjacent_cells.select { |c| c[:x] == cell[:x] && c[:y] == cell[:y] }.any?
    types << 'three_head_neighbor' if @three_head_neighbors.select { |c| c[:x] == cell[:x] && c[:y] == cell[:y] }.any?
    types << 'shorter_snake_heads' if @shorter_snake_heads.select { |c| c[:x] == cell[:x] && c[:y] == cell[:y] }.any?
    

    # Determine the direction between this cell and the snake's head
    direction = direction_between(@head[:x], @head[:y], cell[:x], cell[:y])

    # Determine the opposite direction between this cell and the snake's head
    opposite_direction = opposite_direction(@head[:x], @head[:y], cell[:x], cell[:y])

    # Determine the possible directions between this cell and the snake's head
    possible_directions = possible_directions_between(@head[:x], @head[:y], cell[:x], cell[:y])

    # Determine the neighbors of this cell
    neighbors = neighbors_of(cell[:x], cell[:y])

    # Add x, y coordinates, types, and direction to the cell
    cell[:x] = cell[:x]
    cell[:y] = cell[:y]
    cell[:types] = types
    # Each cell has a score, which is the sum of the @cell_base_score and score_multiplier for each type of cell
    cell[:score] = if types.any?
                     types.map do |type|
                       @score_multiplier[type]
                     end.reduce(:+) + @cell_base_score
                   else
                     @cell_base_score
                   end
    cell[:direction] = direction
    cell[:possible_directions] = possible_directions
    cell[:opposite_direction] = opposite_direction
    cell[:neighbors] = neighbors

    # Add the cell to the turn_score_array
    @turn_score_array << cell
  end

  # puts "Turn score array is: #{@turn_score_array}"


  # Direction of highest score cell in the @turn_score_array
  @highest_score_direction = @turn_score_array.max_by { |cell| cell[:score] }[:direction]
  puts "Highest score cell direction is: #{@highest_score_direction}"

  # If our @health is above the @health_threshold, set the multiplier to 1
  # If our @health is below the @health_threshold, set the multiplier to 2
  if @health > @health_threshold
    @top_direction_score_multiplier = 0
  else
    @top_direction_score_multiplier = 15
  end

  # For every cell in the turn_score_array, add types 'top_direction' if the cell's direction is the same as @highest_score_direction and increase the score by @top_direction_score_multiplier
  @turn_score_array.each do |cell|
    cell[:types] << 'top_direction' if cell[:direction] == @highest_score_direction
    cell[:score] += @top_direction_score_multiplier if cell[:types].include?('top_direction')
  end

  # For each direction, find the number of empty or food cells in that direction, and the total score of all cells in that direction
  # takes the @@turn_score_array as input
  def direction_scores(turn_score_array)
    # Sum the score of each cell for each direction
    @direction_scores = {
      'left' => turn_score_array.select { |cell| cell[:direction] == 'left' }.map { |cell| cell[:score] }.reduce(:+),
      'right' => turn_score_array.select { |cell| cell[:direction] == 'right' }.map { |cell| cell[:score] }.reduce(:+),
      'up' => turn_score_array.select { |cell| cell[:direction] == 'up' }.map { |cell| cell[:score] }.reduce(:+),
      'down' => turn_score_array.select { |cell| cell[:direction] == 'down' }.map { |cell| cell[:score] }.reduce(:+)
    }
  end

    # For each possible direction, find the number of empty or food cells in that direction, and the total score of all cells in that direction
    def direction_scores_possible(turn_score_array)
      # Sum the score of each cell for each direction
      @direction_scores_possible = {
        'left' => turn_score_array.select { |cell| cell[:possible_directions].include?('left') }.map { |cell| cell[:score] }.reduce(:+),
        'right' => turn_score_array.select { |cell| cell[:possible_directions].include?('right') }.map { |cell| cell[:score] }.reduce(:+),
        'up' => turn_score_array.select { |cell| cell[:possible_directions].include?('up') }.map { |cell| cell[:score] }.reduce(:+),
        'down' => turn_score_array.select { |cell| cell[:possible_directions].include?('down') }.map { |cell| cell[:score] }.reduce(:+)
      }
    end

    # For each set of two possible directions, find the number of empty or food cells in that set of directions, and the total score of all cells in that direction
    def direction_scores_possible_2(turn_score_array)
      # Sum the score of each cell for each direction
      @direction_scores_possible_2 = {
        'left_up' => turn_score_array.select { |cell| cell[:possible_directions].include?('left') && cell[:possible_directions].include?('up') }.map { |cell| cell[:score] }.reduce(:+),
        'left_down' => turn_score_array.select { |cell| cell[:possible_directions].include?('left') && cell[:possible_directions].include?('down') }.map { |cell| cell[:score] }.reduce(:+),
        'right_up' => turn_score_array.select { |cell| cell[:possible_directions].include?('right') && cell[:possible_directions].include?('up') }.map { |cell| cell[:score] }.reduce(:+),
        'right_down' => turn_score_array.select { |cell| cell[:possible_directions].include?('right') && cell[:possible_directions].include?('down') }.map { |cell| cell[:score] }.reduce(:+)
      }
    end

  @possible_turns = []
  # Select my possible turns from the @turn_score_array. A possible turn is a direction to a head_neighbor that has a score greater than 0.
  @turn_score_array.select { |cell| cell[:types].include?('head_neighbor') && (cell[:score]).positive? }.each do |cell|
    @possible_turns << cell
  end
    
  
  # If game mode is 'wrapped', if our head is on the edge of the map, find the cell on the opposite side of the map and add it to the @possible_turns
  if @game_mode == 'wrapped'
    if @head[:x] == 0
      opposite_edge = opposite_edge_cell(@head[:x], @head[:y])
      @turn_score_array.select { |cell| cell[:x] == opposite_edge[:x] && cell[:y] == opposite_edge[:y] && (cell[:score]).positive? }.each do |cell|
        # invert the direction of the cell
        cell[:direction] = invert_direction(cell[:direction])
        @possible_turns << cell
      end
    elsif @head[:x] == @width - 1
      opposite_edge = opposite_edge_cell(@head[:x], @head[:y])
      @turn_score_array.select { |cell| cell[:x] == opposite_edge[:x] && cell[:y] == opposite_edge[:y] && (cell[:score]).positive? }.each do |cell|
        # invert the direction of the cell
        cell[:direction] = invert_direction(cell[:direction])
        @possible_turns << cell
      end
    elsif @head[:y] == 0
      opposite_edge = opposite_edge_cell(@head[:x], @head[:y])
      @turn_score_array.select { |cell| cell[:x] == opposite_edge[:x] && cell[:y] == opposite_edge[:y] && (cell[:score]).positive? }.each do |cell|
        # invert the direction of the cell
        cell[:direction] = invert_direction(cell[:direction])
        @possible_turns << cell
      end
    elsif @head[:y] == @height - 1
      opposite_edge = opposite_edge_cell(@head[:x], @head[:y])
      @turn_score_array.select { |cell| cell[:x] == opposite_edge[:x] && cell[:y] == opposite_edge[:y] && (cell[:score]).positive? }.each do |cell|
        # invert the direction of the cell
        cell[:direction] = invert_direction(cell[:direction])
        @possible_turns << cell
      end
    end
  end


  # Load directions in @possible_turns into @possible_moves
  @possible_moves = @possible_turns.map { |cell| cell[:direction] }

  # @possible_moves = ['up', 'down', 'left', 'right']
  # If head is at edge of board, then remove the direction from @possible_moves
  if @game_mode != 'wrapped'
    @possible_moves.delete('left') if (@head[:x]).zero?
    @possible_moves.delete('right') if @head[:x] == @width - 1
    @possible_moves.delete('down') if (@head[:y]).zero?
    @possible_moves.delete('up') if @head[:y] == @height - 1
  end

  # If game mode is 'wrapped', and head is at edge of board, then add the direction off the edge of the board to @possible_moves
  if @game_mode == 'wrapped'
    @possible_moves.push('left') if (@head[:x]).zero?
    @possible_moves.push('right') if @head[:x] == @width - 1
    @possible_moves.push('down') if (@head[:y]).zero?
    @possible_moves.push('up') if @head[:y] == @height - 1
  end

  # Once our snake's length is greater than that of any other snake.
  # then we need to find the direction of the nearest snake's head and set @move_direction to that direction if it is in @possible_moves
  # DISABLED: This is now handled by the enhanced decision logic below
  # @snakes_info.each do |snake|
  #   next unless snake[:length] < @length - 3
  # 
  #   puts "Snake named #{snake[:name]} is shorter than me. It's length is #{snake[:length]} and mine is #{@length}"
  #   # Find the direction between our head and any shorter snake's head
  #   direction = direction_between(@head[:x], @head[:y], snake[:head][:x], snake[:head][:y])
  #   # If the direction is in @possible_moves, then set @move_direction to that direction
  #   if @possible_moves.include?(direction)
  #     puts "I'm going to move #{direction} because I'm going to eat a snake named #{snake[:name]}"
  #     @move_direction = direction
  #   end
  # 
  #   # If we are the longest by at least 2 cells, reduce our @health_threshold by 1
  #   if @length - snake[:length] >= 5
  #     @health_threshold -= 1
  #     # Clamp the health threshold to a minimum of 55
  #     @health_threshold = 55 if @health_threshold < 55
  #     puts "I'm going to eat a snake named #{snake[:name]}. I'm going to reduce my health_threshold by 1 to #{@health_threshold}"
  #   end
  # end

  # Get highest score in @possible_turns
  @highest_score = @possible_turns.max_by { |turn| turn[:score] }

  # Create board state object for helper functions
  board_state = {
    head: @head,
    food: @food,
    hazards: @hazards,
    snakes: @snakes,
    snakes_heads_not_my_head: @snakes_heads_not_my_head,
    all_occupied_cells: @all_occupied_cells,
    head_neighbors: @head_neighbors,
    length: @length,
    width: @width,
    height: @height,
    game_mode: @game_mode
  }

  # Enhanced decision making with advanced algorithms
  
  # 1. First priority: Use A* pathfinding if we need food and health is low
  if @health < @health_threshold && !@food.empty?
    astar_move = a_star_to_food(board_state)
    if astar_move && @possible_moves.include?(astar_move)
      puts "Using A* pathfinding to get food: #{astar_move}"
      @move_direction = astar_move
    end
  end

  # 2. Second priority: Space control - avoid getting trapped
  unless @move_direction
    space_control = get_space_control_move(board_state)
    min_space_required = [(@width * @height * 0.3).to_i, @length * 2].max
    
    if space_control[:space_size] >= min_space_required && space_control[:move] && @possible_moves.include?(space_control[:move])
      puts "Using space control move: #{space_control[:move]} (space: #{space_control[:space_size]})"
      @move_direction = space_control[:move]
    end
  end

  # 3. Third priority: Attack weaker snakes if we're significantly longer
  unless @move_direction
    @snakes_info.each do |snake|
      if snake[:length] < @length - 3
        attack_direction = direction_between(@head[:x], @head[:y], snake[:head][:x], snake[:head][:y])
        if @possible_moves.include?(attack_direction)
          # But only attack if we won't get trapped
          next_pos = case attack_direction
                    when 'up' then { x: @head[:x], y: @head[:y] + 1 }
                    when 'down' then { x: @head[:x], y: @head[:y] - 1 }
                    when 'left' then { x: @head[:x] - 1, y: @head[:y] }
                    when 'right' then { x: @head[:x] + 1, y: @head[:y] }
                    end
          
          space_after_attack = flood_fill_from(next_pos, board_state)
          if space_after_attack >= @length + 5
            puts "Attacking weaker snake #{snake[:name]}: #{attack_direction}"
            @move_direction = attack_direction
            break
          end
        end
      end
    end
  end

  # 4. Fourth priority: Avoid predicted enemy moves
  unless @move_direction
    enemy_predictions = predict_enemy_moves(board_state)
    safe_moves = @possible_moves.select do |move|
      next_pos = case move
                when 'up' then { x: @head[:x], y: @head[:y] + 1 }
                when 'down' then { x: @head[:x], y: @head[:y] - 1 }
                when 'left' then { x: @head[:x] - 1, y: @head[:y] }
                when 'right' then { x: @head[:x] + 1, y: @head[:y] }
                end
      
      # Check if any predicted enemy move would collide with our next position
      safe = true
      enemy_predictions.each do |enemy_id, predicted_pos|
        if predicted_pos && predicted_pos[:x] == next_pos[:x] && predicted_pos[:y] == next_pos[:y]
          enemy_snake = @snakes.find { |s| s[:id] == enemy_id }
          if enemy_snake && enemy_snake[:length] >= @length
            safe = false
            break
          end
        end
      end
      safe
    end
    
    if !safe_moves.empty?
      # Choose the safest move with highest score
      best_safe_move = safe_moves.max_by do |move|
        turn = @possible_turns.find { |t| t[:direction] == move }
        turn ? turn[:score] : 0
      end
      
      if best_safe_move
        puts "Using safe move avoiding enemy predictions: #{best_safe_move}"
        @move_direction = best_safe_move
      end
    end
  end

  # 5. Final fallback: Use the highest scoring move that's actually possible
  unless @move_direction
    if @highest_score.nil? || !@possible_moves.include?(@highest_score[:direction])
      # Choose any possible move (prefer ones that aren't walls)
      @move_direction = @possible_moves.first || 'up'
    else
      @move_direction = @highest_score[:direction]
    end
  end

  #puts "Move direction is: #{@move_direction} - highest score is: #{@highest_score[:score]} - turn is: #{@highest_score[:types]} to the #{@highest_score[:direction]}"

  #TODO Function to use A* to find the safest path to food
  # A safe path is one that stays away from longer snakes, bodies, and hazards
  

  # Output the end time in ms
  end_time = Time.now
  puts "End time is: #{end_time} - took #{end_time - start_time} seconds"

  debug = false
# Debug output, only if debug is true
  if debug

  puts "Possible moves are: 
  #{@possible_moves}"

  puts "possible_turns are: 
  #{@possible_turns}"

  puts "Highest score is #{@highest_score}"

  # Most common cell types from @turn_score_array and their counts and scores
  @turn_score_array.group_by { |cell| cell[:types] }.map { |types, cells| [types, cells.count] }.sort_by { |types, count| count }.reverse.each do |types, count|
    puts "Most common #{types} - #{count}"
  end

  # Least common 5 cell types from @turn_score_array and their counts
  @turn_score_array.group_by { |cell| cell[:types] }.map { |types, cells| [types, cells.count] }.sort_by { |types, count| count }.first(5).each do |types, count|
    puts "Least common #{types} - #{count}"
  end

  # Top 5 highest scores from @turn_score_array and their counts
  @turn_score_array.group_by { |cell| cell[:score] }.map { |score, cells| [score, cells.count] }.sort_by { |score, count| score }.reverse.first(5).each do |score, count|
    puts "highest scores #{score} - #{count}"
  end

  # Lowest 5 scores from @turn_score_array and their counts
  @turn_score_array.group_by { |cell| cell[:score] }.map { |score, cells| [score, cells.count] }.sort_by { |score, count| score }.first(5).each do |score, count|
    puts "lowest scores #{score} - #{count}"
  end

  # Most common cell types and score combinations from @turn_score_array
  @turn_score_array.group_by { |cell| cell[:types] }.map { |types, cells| [types, cells.map { |cell| cell[:score] }.reduce(:+)] }.sort_by { |types, score| score }.reverse.each do |types, score|
    puts "Most common #{types} - #{score}"
  end
end

  # TODO:
  # Generate a ascii representation of the board
  # Cells are placed in their x,y coordianres on a grid the of size @width x @height
  # Each cell is represented by a single character
  # Board edges are represented by '#'
  # Food is represented by 'F'
  # Snake head is represented by 'H'
  # Snake body is represented by 'B'
  # Snake tail is represented by 'T'
  # Empty cells are represented by '0'
  # Snake head neighbors are represented by 'h'
  # Snake body neighbors are represented by 'b'
  # Hazard cells are represented by 'X'

  


  puts "MOVE: #{@move_direction} - TURN: #{board[:turn]}"
  { move: @move_direction }
end
