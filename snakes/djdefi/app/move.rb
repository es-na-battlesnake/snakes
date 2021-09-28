# frozen_string_literal: true

$VERBOSE = nil
$stdout.sync = true
# Health find threshold variable
@@health_threshold = 85

# This function is called on every turn of a game. It's how your Battlesnake decides where to move.
# Valid moves are "up", "down", "left", or "right".
# TODO: Use the information in board to decide your next move.
def move(board)
  # Record the start time of the turn
  start_time = Time.now

  puts board

  # Example board object:
  # {:game=>{:id=>"f767ba58-945c-4f5a-b5b6-12990dc27ab1", :ruleset=>{:name=>"standard", :version=>"v1.0.17"}, :timeout=>500}, :turn=>0, :board=>{:height=>11, :width=>11, :snakes=>[{:id=>"gs_9PwkMwt7S3CtB9vFGjVbH39V", :name=>"ruby-danger-noodle", :latency=>"", :health=>100, :body=>[{:x=>9, :y=>9}, {:x=>9, :y=>9}, {:x=>9, :y=>9}], :head=>{:x=>9, :y=>9}, :length=>3, :shout=>""}, {:id=>"gs_qrT8RGkMKCyYCtpphtkTfQkX", :name=>"LoopSnake", :latency=>"", :health=>100, :body=>[{:x=>9, :y=>1}, {:x=>9, :y=>1}, {:x=>9, :y=>1}], :head=>{:x=>9, :y=>1}, :length=>3, :shout=>""}], :food=>[{:x=>8, :y=>10}, {:x=>8, :y=>2}, {:x=>5, :y=>5}], :hazards=>[]}, :you=>{:id=>"gs_9PwkMwt7S3CtB9vFGjVbH39V", :name=>"ruby-danger-noodle", :latency=>"", :health=>100, :body=>[{:x=>9, :y=>9}, {:x=>9, :y=>9}, {:x=>9, :y=>9}], :head=>{:x=>9, :y=>9}, :length=>3, :shout=>""}}

  # Puts board height and width
  @height = board[:board][:height]
  @width = board[:board][:width]

  # Puts all the snakes in an array
  @snakes = board[:board][:snakes] || []
  # puts "There are the following snakes: #{@snakes}"

  # Puts all the food in an array
  @food = board[:board][:food] || []
  # puts "There is food at: #{@food}"

  # Puts all the hazards in an array
  @hazards = board[:board][:hazards] || []
  # puts "There are hazards at: #{@hazards}"

  # Puts the snakes length
  @length = board[:you][:length]
  # puts "My length is: #{@length}"

  # Puts the tail cells of all the snakes
  @snake_tails = []
  @snakes.each do |snake|
    @snake_tails << snake[:body][-1]
  end

  # Puts x, y coordinates hash of all cells on the board
  @board_hash = board[:board][:height].times.map do |i|
    board[:board][:width].times.map do |j|
      { x: j, y: i }
    end
  end.flatten
  # puts "All board cells are at: #{@board_hash}"

  # Puts x, y coordinates hash of my snake's head
  @head = board[:you][:head]
  # puts "My head is at: #{@head}"

  # Puts x, y coordinates hash of my snake's body
  @body = board[:you][:body].map { |b| { x: b[:x], y: b[:y] } }.flatten
  # puts "My body is at: #{@body}"

  # Puts where all other snakes bodies and heads are
  @snakes_bodies = board[:board][:snakes].map { |s| s[:body] }.flatten + @body || []

  # Puts where all snakes heads are
  @snakes_heads = board[:board][:snakes].map { |s| s[:head] }.flatten || []
  # puts "All snakes heads are at: #{@snakes_heads}"

  # Puts where all snakes heads are, but not my head
  @snakes_heads_not_my_head = board[:board][:snakes].map { |s| s[:head] }.flatten - [@head] || []

  # Puts where all snakes bodies are, but not my body
  @snakes_bodies_not_my_body = board[:board][:snakes].map { |s| s[:body] }.flatten - @body || []

  # Puts cells that are food within one move of my head at the same as being within once move of any other snake's head
  @food_within_one_move_of_snake_head = @food.select do |f|
    @snakes_heads_not_my_head.any? do |s|
      (f[:x] - s[:x]).abs <= 1 && (f[:y] - s[:y]).abs <= 1
    end
  end
  # puts "Food within one move of snake head: #{@food_within_one_move_of_snake_head}"

  # Puts where all food cells which are also hazard cells
  @food_hazards = @food.select do |f|
    @hazards.any? do |h|
      f[:x] == h[:x] && f[:y] == h[:y]
    end
  end

  # Nearest food cell x,y to my head: #{@closest_food_cell_to_my_head}"
  @closest_food_cell_to_my_head = @food.min_by do |f|
    (f[:x] - @head[:x]).abs + (f[:y] - @head[:y]).abs
  end

  # puts "Nearest food cell to my head: #{@closest_food_cell_to_my_head}"

  # Function to determine x,y coordinate pair hash of each cell adjacent to the head
  def adjacent_cells(x, y)
    [{ x: x - 1, y: y }, { x: x + 1, y: y }, { x: x, y: y - 1 }, { x: x, y: y + 1 }]
  end

  @head_neighbors = adjacent_cells(@head[:x], @head[:y])

  # puts "My head neighbors are: #{@head_neighbors}"

  @other_snakes_head_neighbors = @snakes_heads_not_my_head.map { |s| adjacent_cells(s[:x], s[:y]) }.flatten

  # puts "Other snakes head neighbors are: #{@other_snakes_head_neighbors}"

  # Shared neighbors are cells which are in both @head_neighbors and @other_snakes_head_neighbors
  @shared_neighbors = @head_neighbors.select { |h| @other_snakes_head_neighbors.include?(h) }
  puts "Shared neighbors are: #{@shared_neighbors}"

  # Id, Name, total Lengths, Coordinates of all snakes heads
  @snakes_info = board[:board][:snakes].map do |s|
    { id: s[:id], name: s[:name], length: s[:body].length, head: s[:head], head_neighbors: adjacent_cells(s[:head][:x], s[:head][:y]) }
  end

  # @shared_shorter_snakes are cells which are in both @head_neighbors and @other_snakes_head_neighbors and where the length of the neighboring snake is shorter than my snake
  @shared_shorter_snakes = @shared_neighbors.select do |s|
    @snakes_info.any? do |snake|
      snake[:head_neighbors].include?(s) && snake[:length] < @length
    end
  end

  # @shared_longer_snakes are cells which are in both @head_neighbors and @other_snakes_head_neighbors and where the length of the neighboring snake is longer than my snake
  @shared_longer_snakes = @shared_neighbors.select do |s|
    @snakes_info.any? do |snake|
      snake[:head_neighbors].include?(s) && snake[:length] > @length
    end
  end

  # @shared_same_length_snakes are cells which are in both @head_neighbors and @other_snakes_head_neighbors and where the length of the neighboring snake is the same as my snake
  @shared_same_length_snakes = @shared_neighbors.select do |s|
    @snakes_info.any? do |snake|
      snake[:head_neighbors].include?(s) && snake[:length] == @length
    end
  end


  #puts "Shared same length snakes are: #{@shared_same_length_snakes}"
  #puts "Shared shorter snakes are: #{@shared_shorter_snakes}"
  #puts "Shared longer snakes are: #{@shared_longer_snakes}"

  # Each time the snake eats a piece of food, its tail grows longer, making the game increasingly difficult.
  # The user controls the direction of the snake's head (up, down, left, or right), and the snake's body follows. The player cannot stop the snake from moving while the game is in progress.
  # The board is a 2-dimensional array of cells, each cell containing a hash with x and y coordinates. The board is of variable size, and is surronded by walls.
  # Other snakes and hazards are present on the board and should be avoided.
  # The board is updated every turn.

  @my_snake = @snakes.select { |s| s[:id] == board[:you][:id] }

  # Function to check if a cell is a wall
  def is_wall?(x, y)
    if x.negative? || y.negative? || x > @width || y > @height
      true
    else
      false
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
  # puts "All occupied cells are: #{@all_occupied_cells}"

  # x, y coordinates hash of all empty cells on the board
  @empty_cells = @board_hash - @all_occupied_cells
  # puts "All empty cells are: #{@empty_cells}"

  # x, y coordinates of each corner cell
  @corners = [{ x: 0, y: 0 }, { x: @width - 1, y: 0 }, { x: 0, y: @height - 1 },
              { x: @width - 1, y: @height - 1 }]

  # Function to determine the direction between two cell x,y coordinates from the perspective of the snake
  def direction_between(x1, y1, x2, y2)
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

  # Function to find the neighbors of a given cell x,y coordinates
  def neighbors_of(x, y)
    adjacent_cells(x, y)
  end

  # Cell base score
  @cell_base_score = 100

  # Set score multiplier for each type of cell
  @score_multiplier = {
    'wall' => -10,
    'hazard' => -2,
    'food' => 7,
    'food_hazard' => 2,
    'shared_neighbor' => -3,
    'shared_shorter_snake' => 5,
    'shared_longer_snake' => -15,
    'shared_same_length_snake' => 1,
    'empty' => 15,
    'snake_head' => -4,
    'snake_body' => -4,
    'corner' => -5,
    'other_snake_head' => -4,
    'other_snake_body' => -15,
    'body' => -14,
    'head' => -4,
    'tail' => 4,
    'head_neighbor' => 0
  }

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
    # types << 'head' if @head.select { |c| c[:x] == cell[:x] && c[:y] == cell[:y] }.any?
    types << 'food' if @food.select { |c| c[:x] == cell[:x] && c[:y] == cell[:y] }.any?
    types << 'food_hazard' if @food_hazards.select { |c| c[:x] == cell[:x] && c[:y] == cell[:y] }.any?
    types << 'hazard' if @hazards.select { |c| c[:x] == cell[:x] && c[:y] == cell[:y] }.any?
    types << 'shared_neighbor' if @shared_neighbors.select { |c| c[:x] == cell[:x] && c[:y] == cell[:y] }.any?
    types << 'shared_shorter_snake' if @shared_shorter_snakes.select { |c| c[:x] == cell[:x] && c[:y] == cell[:y] }.any?
    types << 'shared_longer_snake' if @shared_longer_snakes.select { |c| c[:x] == cell[:x] && c[:y] == cell[:y] }.any?
    types << 'shared_same_length_snake' if @shared_same_length_snakes.select { |c| c[:x] == cell[:x] && c[:y] == cell[:y] }.any?
    types << 'empty' if @empty_cells.select { |c| c[:x] == cell[:x] && c[:y] == cell[:y] }.any?
    types << 'head_neighbor' if @head_neighbors.select { |c| c[:x] == cell[:x] && c[:y] == cell[:y] }.any?

    # Determine the direction between this cell and the snake's head
    direction = direction_between(@head[:x], @head[:y], cell[:x], cell[:y])

    # Determine the opposite direction between this cell and the snake's head
    opposite_direction = opposite_direction(@head[:x], @head[:y], cell[:x], cell[:y])

    # Determine the neighbors of this cell
    neighbors = neighbors_of(cell[:x], cell[:y])

    # Add x, y coordinates, types, and direction to the cell
    cell[:x] = cell[:x]
    cell[:y] = cell[:y]
    cell[:types] = types
    cell[:direction] = direction
    cell[:opposite_direction] = opposite_direction
    cell[:neighbors] = neighbors

    # Each cell has a score, which is the sum of the @cell_base_score and score_multiplier for each type of cell
    cell[:score] = if types.any?
                     types.map do |type|
                       @score_multiplier[type]
                     end.reduce(:+) + @cell_base_score
                   else
                     @cell_base_score
                   end

    # Add the cell to the turn_score_array
    @turn_score_array << cell
  end

  # puts "Turn score array is: #{@turn_score_array}"

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

    # Flatten to remove nil scores
    @direction_scores.each do |direction, score|
      @direction_scores[direction] = score.nil? ? 0 : score
    end
  end

  @possible_turns = []
  # Select my possible turns from the @turn_score_array. A possible turn is a direction to a head_neighbor that has a score greater than 0.
  @turn_score_array.select { |cell| cell[:types].include?('head_neighbor') && (cell[:score]).positive? }.each do |cell|
    @possible_turns << cell
  end

  # Load directions in @possible_turns into @possible_moves
  @possible_moves = @possible_turns.map { |cell| cell[:direction] }

  # @possible_moves = ['up', 'down', 'left', 'right']
  # If head is at edge of board, then remove the direction from @possible_moves
  @possible_moves.delete('left') if (@head[:x]).zero?
  @possible_moves.delete('right') if @head[:x] == @width
  @possible_moves.delete('down') if (@head[:y]).zero?
  @possible_moves.delete('up') if @head[:y] == @height

  # Once our snake's length is greater than that of any other snake.
  # then we need to find the direction of the nearest snake's head and set @move_direction to that direction if it is in @possible_moves
  @snakes_info.each do |snake|
    next unless snake[:length] < @length

    puts "Snake named #{snake[:name]} is shorter than me. It's length is #{snake[:length]} and mine is #{@length}"
    # Find the direction between our head and any shorter snake's head
    direction = direction_between(@head[:x], @head[:y], snake[:head][:x], snake[:head][:y])
    # If the direction is in @possible_moves, then set @move_direction to that direction
    if @possible_moves.include?(direction)
      puts "I'm going to move #{direction} because I'm going to eat a snake named #{snake[:name]}"
      @move_direction = direction
    end
  end

  # If top score direction is a possible move, then increase the score of that direction in the @possible_turns by X
  if @possible_moves.include?(@top_score_direction)
    puts 'Top score direction is a possible move!'
    @possible_turns.each do |turn|
      next unless turn[:direction] == @top_score_direction

      turn[:score] += 50
      turn[:type] = 'top_score'
      puts "Top score direction is: #{@top_score_direction}!"
    end
  end

  # If our health drops below 50, find direction of the nearest food and set @move_direction to that direction
  @health = board[:you][:health]
  if @health < @@health_threshold
    @record_low_health = @health
    puts "Health is: #{@health}!! Finding food"
    # Find direction of @closest_food_cell_to_my_head - if possible move that direction
    if @possible_moves.include?(direction_between(@head[:x], @head[:y], @closest_food_cell_to_my_head[:x], @closest_food_cell_to_my_head[:y]))
      @move_direction = direction_between(@head[:x], @head[:y], @closest_food_cell_to_my_head[:x], @closest_food_cell_to_my_head[:y])
    # if @health is still below @@health_threshold, increase the @@health_threshold
    elsif @health < @@health_threshold
      @@health_threshold += 1
      puts "Health threshold is now: #{@@health_threshold}"
    end
  end
  
    
  # Get highest score in @possible_turns
  @highest_score = @possible_turns.max_by { |turn| turn[:score] }

  # Set @move_direction to the direction of the highest score object
  @move_direction = @highest_score[:direction]
  
  # If more than 1 possible_turns have the highest score, prefer the direction between by head and @closest_food_cell_to_my_head
  if @possible_turns.count { |turn| turn[:score] == @highest_score[:score] } > 1
    puts "There are #{@possible_turns.count { |turn| turn[:score] == @highest_score[:score] }} possible turns with the highest score of #{@highest_score[:score]}"
    if @possible_turns.select { |turn| turn[:score] == @highest_score[:score] }.map { |turn| turn[:direction] }.include?(direction_between(@head[:x], @head[:y], @closest_food_cell_to_my_head[:x], @closest_food_cell_to_my_head[:y]))
      @move_direction = direction_between(@head[:x], @head[:y], @closest_food_cell_to_my_head[:x], @closest_food_cell_to_my_head[:y])
      puts "I'm going to move #{@move_direction} because I'm going to eat a food cell"
    end
  else # If only 1 possible_turns has the highest score, then set @move_direction to that direction
    @highest_score = @possible_turns.sample
    puts "I'm going to move #{@highest_score[:direction]} because I have a tie for the highest score at #{@highest_score[:score]}"
  end


  puts "possible_turns are: #{@possible_turns}"

  puts "Possible moves are: #{@possible_moves}"

  puts "Move direction is: #{@move_direction} - highest score is: #{@highest_score[:score]} - turn is: #{@highest_score[:types]} to the #{@highest_score[:direction]}"


  if @possible_moves.include?(@move_direction_force)
    puts 'Forced move direction is a possible move!'
    @move_direction = @move_direction_force
  end

  # Output the end time in ms
  end_time = Time.now
  puts "End time is: #{end_time} - took #{end_time - start_time} seconds"

  puts "MOVE: #{@move_direction}"
  { "move": @move_direction }
end
