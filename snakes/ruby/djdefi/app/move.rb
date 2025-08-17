# frozen_string_literal: true

require 'set'
require_relative 'elite_strategies'

$VERBOSE = nil
$stdout.sync = true

# Include elite strategies for 90%+ win rate performance
include EliteStrategies

# A* pathfinding to find the safest path to food - optimized version
def a_star_to_food(board_state, start_time = nil, timeout_limit = nil)
  return nil if board_state[:food].empty?
  
  closest_food = board_state[:food].min_by { |f| manhattan_distance(board_state[:head], f) }
  path = a_star_pathfind_optimized(board_state[:head], closest_food, board_state, start_time, timeout_limit)
  
  return nil if path.nil? || path.length < 2
  
  # Return the direction to the next step in the path
  next_step = path[1]
  direction_between(board_state[:head][:x], board_state[:head][:y], next_step[:x], next_step[:y])
end

# Manhattan distance between two points
def manhattan_distance(point1, point2)
  (point1[:x] - point2[:x]).abs + (point1[:y] - point2[:y]).abs
end

# A* pathfinding algorithm - optimized version with timeout and max iterations
def a_star_pathfind_optimized(start, goal, board_state, start_time = nil, timeout_limit = nil)
  open_set = [start]
  came_from = {}
  g_score = { start => 0 }
  f_score = { start => manhattan_distance(start, goal) }
  max_iterations = 200  # Limit iterations for performance
  iterations = 0
  
  while !open_set.empty? && iterations < max_iterations
    iterations += 1
    
    # Check timeout every 10 iterations
    if start_time && timeout_limit && iterations % 10 == 0
      return nil if (Time.now - start_time) > timeout_limit
    end
    
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
  
  nil # No path found or timeout
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

# Flood fill to avoid dead ends - optimized version with early termination
def flood_fill_from(start_pos, board_state, max_depth = nil)
  return 0 if max_depth == 0
  
  visited = Set.new
  queue = [start_pos]
  visited.add(start_pos)
  depth = 0
  
  while !queue.empty?
    current = queue.shift
    depth += 1
    
    # Early termination for performance - if we have enough space, return early
    if max_depth && depth >= max_depth
      return depth
    end
    
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

# Cached space control calculation to avoid repeated flood fills
def get_space_control_move_optimized(board_state, start_time, timeout_limit)
  best_move = nil
  largest_space = 0
  space_cache = {}
  
  board_state[:head_neighbors].each do |neighbor|
    return { move: best_move, space_size: largest_space } if check_timeout(start_time, timeout_limit)
    
    next if is_wall_for_board?(neighbor[:x], neighbor[:y], board_state)
    next if is_occupied_for_board?(neighbor[:x], neighbor[:y], board_state)
    
    neighbor_key = "#{neighbor[:x]},#{neighbor[:y]}"
    
    # Use cached result if available
    if space_cache[neighbor_key]
      space_size = space_cache[neighbor_key]
    else
      # Limit flood fill depth for performance
      required_space = [board_state[:length] * 3, 30].min
      space_size = flood_fill_from(neighbor, board_state, required_space + 10)
      space_cache[neighbor_key] = space_size
    end
    
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
  move_timeout = 0.42 # 420ms timeout for more conservative safety margin
  
  # Current turn number for strategy adaptation
  turn_number = board[:turn] || 0
  
  # Timeout checking function
  def check_timeout(start_time, timeout_limit)
    (Time.now - start_time) > timeout_limit
  end

  # ELITE STRATEGY: Dynamic health threshold based on game state
  longest_enemy_length = (board[:board][:snakes] || []).reject { |s| s[:id] == board[:you][:id] }.map { |s| s[:length] }.max || 0
  our_length = board[:you][:length].to_i
  
  if our_length > longest_enemy_length + 3
    @health_threshold = 75  # More aggressive when winning
  elsif our_length < longest_enemy_length
    @health_threshold = 90  # More conservative when losing  
  else
    @health_threshold = 85  # Default conservative strategy
  end
  @health_threshold = @health_threshold.clamp(0, 100)

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

  @all_occupied_cells = (@snakes_heads + @snakes_bodies + [@head] + @body).flatten

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

  # Initialize score multiplier first
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

  # Dynamic scoring based on game state - adjust after initialization
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
    # Critical: More robust wall detection
    @possible_moves.delete('left') if @head[:x] <= 0
    @possible_moves.delete('right') if @head[:x] >= @width - 1
    @possible_moves.delete('down') if @head[:y] <= 0
    @possible_moves.delete('up') if @head[:y] >= @height - 1
  end

  # If game mode is 'wrapped', and head is at edge of board, then add the direction off the edge of the board to @possible_moves
  if @game_mode == 'wrapped'
    # SURGICAL FIX: Ensure all directions are available in wrapped mode
    ['up', 'down', 'left', 'right'].each do |direction|
      @possible_moves.push(direction) unless @possible_moves.include?(direction)
    end
    puts "Wrapped mode: All directions available: #{@possible_moves}"
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

  # Create enhanced board state object for elite algorithms
  board_state = {
    head: @head,
    food: @food,
    hazards: @hazards,
    snakes: @snakes,
    snakes_heads_not_my_head: @snakes_heads_not_my_head,
    all_occupied_cells: @all_occupied_cells,
    head_neighbors: @head_neighbors,
    length: @length,
    health: @health,
    width: @width,
    height: @height,
    game_mode: @game_mode,
    our_id: board[:you][:id],
    turn: turn_number
  }

  # ELITE DECISION SYSTEM - Multi-layered approach for 90%+ win rate
  
  # Layer 1: Perfect Safety - Never make avoidable mistakes
  unless @move_direction
    perfect_safe_moves = @possible_moves.select do |move|
      next_pos = case move
                when 'up' then { x: @head[:x], y: @head[:y] + 1 }
                when 'down' then { x: @head[:x], y: @head[:y] - 1 }
                when 'left' then { x: @head[:x] - 1, y: @head[:y] }
                when 'right' then { x: @head[:x] + 1, y: @head[:y] }
                end
      
      # Must pass all safety checks
      safety_checks = [
        # No wall collisions (unless wrapped)
        @game_mode == 'wrapped' || (next_pos[:x] >= 0 && next_pos[:x] < @width && next_pos[:y] >= 0 && next_pos[:y] < @height),
        
        # No body collisions
        !@all_occupied_cells.any? { |cell| cell.is_a?(Hash) && cell[:x] == next_pos[:x] && cell[:y] == next_pos[:y] },
        
        # Must have adequate space (no immediate dead ends)
        calculate_space_from_position(next_pos, board_state, @length * 2) >= @length + 3,
        
        # No immediate hazards unless absolutely necessary  
        @hazards.empty? || @possible_moves.length == 1 || !@hazards.any? { |h| h[:x] == next_pos[:x] && h[:y] == next_pos[:y] }
      ]
      
      safety_checks.all?
    end
    
    if perfect_safe_moves.length > 0
      @possible_moves = perfect_safe_moves
      puts "ELITE: Filtered to #{perfect_safe_moves.length} perfectly safe moves"
    else
      puts "ELITE: Warning - no perfectly safe moves available"
    end
  end

  # Layer 2: Elite Multi-Objective Decision Making
  unless @move_direction
    if check_timeout(start_time, move_timeout)
      @move_direction = @possible_moves.first || 'up'
    else
      elite_decision = make_elite_decision(board_state, @possible_moves, turn_number, start_time, move_timeout)
      if elite_decision
        @move_direction = elite_decision
        puts "ELITE: Multi-objective decision selected: #{@move_direction}"
      end
    end
  end

  # 6. Final fallback: Use the highest scoring move that's actually possible and safe
  unless @move_direction
    if @highest_score.nil? || !@possible_moves.include?(@highest_score[:direction])
      # Choose any possible move (prefer ones that aren't walls)
      @move_direction = @possible_moves.first || 'up'
    else
      @move_direction = @highest_score[:direction]
    end
  end

  # CRITICAL: Final emergency safety validation before committing to move
  if @move_direction
    # Calculate where this move will take us
    final_next_pos = case @move_direction
                    when 'up' then { x: @head[:x], y: @head[:y] + 1 }
                    when 'down' then { x: @head[:x], y: @head[:y] - 1 }
                    when 'left' then { x: @head[:x] - 1, y: @head[:y] }
                    when 'right' then { x: @head[:x] + 1, y: @head[:y] }
                    end
    
    # Emergency check for walls
    if @game_mode != 'wrapped'
      if final_next_pos[:x] < 0 || final_next_pos[:x] >= @width || final_next_pos[:y] < 0 || final_next_pos[:y] >= @height
        puts "EMERGENCY: Move #{@move_direction} would hit wall! Finding safe alternative..."
        emergency_safe_moves = ['up', 'down', 'left', 'right'].select do |emove|
          epos = case emove
                when 'up' then { x: @head[:x], y: @head[:y] + 1 }
                when 'down' then { x: @head[:x], y: @head[:y] - 1 }
                when 'left' then { x: @head[:x] - 1, y: @head[:y] }
                when 'right' then { x: @head[:x] + 1, y: @head[:y] }
                end
          # Must be within bounds
          epos[:x] >= 0 && epos[:x] < @width && epos[:y] >= 0 && epos[:y] < @height &&
          # Must not be occupied
          !@all_occupied_cells.any? { |cell| cell.is_a?(Hash) && cell[:x] == epos[:x] && cell[:y] == epos[:y] }
        end
        @move_direction = emergency_safe_moves.first || 'up'
        puts "Emergency safe move selected: #{@move_direction}"
      end
    end
    
    # Emergency check for body collisions
    if @all_occupied_cells.any? { |cell| cell.is_a?(Hash) && cell[:x] == final_next_pos[:x] && cell[:y] == final_next_pos[:y] }
      puts "EMERGENCY: Move #{@move_direction} would hit body! Finding safe alternative..."
      emergency_safe_moves = ['up', 'down', 'left', 'right'].select do |emove|
        epos = case emove
              when 'up' then { x: @head[:x], y: @head[:y] + 1 }
              when 'down' then { x: @head[:x], y: @head[:y] - 1 }
              when 'left' then { x: @head[:x] - 1, y: @head[:y] }
              when 'right' then { x: @head[:x] + 1, y: @head[:y] }
              end
        # Must be within bounds
        safe_bounds = true
        if @game_mode != 'wrapped'
          safe_bounds = epos[:x] >= 0 && epos[:x] < @width && epos[:y] >= 0 && epos[:y] < @height
        end
        # Must not be occupied
        safe_bounds && !@all_occupied_cells.any? { |cell| cell.is_a?(Hash) && cell[:x] == epos[:x] && cell[:y] == epos[:y] }
      end
      @move_direction = emergency_safe_moves.first || 'up'
      puts "Emergency safe move selected: #{@move_direction}"
    end
  end

  # Emergency timeout fallback - if we're taking too long, just pick a safe move
  if check_timeout(start_time, move_timeout) && !@move_direction
    puts "TIMEOUT FALLBACK: Using emergency move selection"
    @move_direction = @possible_moves.first || 'up'
  end

  #puts "Move direction is: #{@move_direction} - highest score is: #{@highest_score[:score]} - turn is: #{@highest_score[:types]} to the #{@highest_score[:direction]}"

  #TODO Function to use A* to find the safest path to food
  # A safe path is one that stays away from longer snakes, bodies, and hazards
  

  # Output the end time in ms
  end_time = Time.now
  execution_time = end_time - start_time
  puts "End time is: #{end_time} - took #{execution_time} seconds"
  
  # Warn if execution is getting close to timeout
  if execution_time > 0.4
    puts "WARNING: Move calculation took #{execution_time}s - approaching timeout!"
  end

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
