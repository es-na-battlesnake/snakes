# frozen_string_literal: true

$VERBOSE = nil
$stdout.sync = true

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
      if x.negative? || y.negative? || x > @width || y > @height
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

  # If game mode is wrapped, use the following score multiplier array
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

def find_matching_cell(cells, x, y)
  cells.find { |c| c[:x] == x && c[:y] == y }
end

def update_types(cell, types)
  [
    ['wall', method(:is_wall?)],
    ['corner', @corners],
    ['other_snake_head', @snakes_heads],
    ['other_snake_body', @snakes_bodies],
    ['body', @body],
    ['tail', @snake_tails],
    ['my_tail', @my_tail],
    ['my_tail_neighbor', @my_tail_neighbors],
    # ['head', @head],
    ['food', @food],
    ['food_hazard', @food_hazards],
    ['hazard', @hazards],
    ['shared_neighbor', @shared_neighbors],
    ['shared_shorter_snake', @shared_shorter_snakes],
    ['shared_longer_snake', @shared_longer_snakes],
    ['shared_same_length_snake', @shared_same_length_snakes],
    ['empty', @empty_cells],
    ['head_neighbor', @head_neighbors],
    ['edge', @edges],
    ['other_snake_head_neighbor', @other_snakes_head_neighbors],
    ['snake_body_neighbor', @snakes_bodies_neighbors],
    ['food_adjacent', @food_adjacent_cells],
    ['hazard_adjacent', @hazard_adjacent_cells],
    ['edge_adjacent', @edge_adjacent_cells],
    ['three_head_neighbor', @three_head_neighbors],
    ['shorter_snake_heads', @shorter_snake_heads]
  ].each do |type, collection|
    if collection.is_a?(Array)
      types << type if find_matching_cell(collection, cell[:x], cell[:y])
    else
      types << type if collection.call(cell[:x], cell[:y])
    end
  end
end

@turn_score_array = []
@board_hash.each do |cell|
  types = []
  update_types(cell, types)

  direction = direction_between(@head[:x], @head[:y], cell[:x], cell[:y])
  opposite_direction = opposite_direction(@head[:x], @head[:y], cell[:x], cell[:y])
  possible_directions = possible_directions_between(@head[:x], @head[:y], cell[:x], cell[:y])
  neighbors = neighbors_of(cell[:x], cell[:y])

  score = types.any? ? types.map { |type| @score_multiplier[type] }.reduce(:+) + @cell_base_score : @cell_base_score

  @turn_score_array << cell.merge(
    types: types,
    score: score,
    direction: direction,
    possible_directions: possible_directions,
    opposite_direction: opposite_direction,
    neighbors: neighbors
  )
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
    @possible_moves.delete('right') if @head[:x] == @width
    @possible_moves.delete('down') if (@head[:y]).zero?
    @possible_moves.delete('up') if @head[:y] == @height
  end

  # If game mode is 'wrapped', and head is at edge of board, then add the direction off the edge of the board to @possible_moves
  if @game_mode == 'wrapped'
    @possible_moves.push('left') if (@head[:x]).zero?
    @possible_moves.push('right') if @head[:x] == @width
    @possible_moves.push('down') if (@head[:y]).zero?
    @possible_moves.push('up') if @head[:y] == @height
  end

  # Once our snake's length is greater than that of any other snake.
  # then we need to find the direction of the nearest snake's head and set @move_direction to that direction if it is in @possible_moves
  @snakes_info.each do |snake|
    next unless snake[:length] < @length - 3

    puts "Snake named #{snake[:name]} is shorter than me. It's length is #{snake[:length]} and mine is #{@length}"
    # Find the direction between our head and any shorter snake's head
    direction = direction_between(@head[:x], @head[:y], snake[:head][:x], snake[:head][:y])
    # If the direction is in @possible_moves, then set @move_direction to that direction
    if @possible_moves.include?(direction)
      puts "I'm going to move #{direction} because I'm going to eat a snake named #{snake[:name]}"
      @move_direction = direction
    end

    # If we are the longest by at least 2 cells, reduce our @health_threshold by 1
    if @length - snake[:length] >= 5
      @health_threshold -= 1
      # Clamp the health threshold to a minimum of 55
      @health_threshold = 55 if @health_threshold < 55
      puts "I'm going to eat a snake named #{snake[:name]}. I'm going to reduce my health_threshold by 1 to #{@health_threshold}"
    end
  end

  # Get highest score in @possible_turns
  @highest_score = @possible_turns.max_by { |turn| turn[:score] }

  # Set @move_direction to the direction of the highest score object
  if @highest_score.nil?
    @move_direction = 'up'
  else
    @move_direction = @highest_score[:direction]
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
  { "move": @move_direction }
end
