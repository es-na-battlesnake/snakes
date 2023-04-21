# frozen_string_literal: true

$VERBOSE = nil
$stdout.sync = true

def move(board)
  start_time = Time.now
  @health_threshold = 99.clamp(0, 100)
  @height, @width = board[:board][:height].to_i, board[:board][:width].to_i
  @snakes, @food, @hazards = board[:board][:snakes] || [], board[:board][:food] || [], board[:board][:hazards] || []
  @health, @length, @game_mode = board[:you][:health].to_i, board[:you][:length].to_i, board[:game][:ruleset][:name]
  @snake_tails = @snakes.map { |snake| snake[:body][-1] }
  @my_tail = [board[:you][:body][-1]]
  @board_hash = @height.times.flat_map { |i| @width.times.map { |j| { x: j, y: i } } }
  @head, @body = board[:you][:head], board[:you][:body].map { |b| { x: b[:x], y: b[:y] } }
  @snakes_heads, @snakes_bodies = @snakes.map { |s| s[:head] }, @snakes.flat_map { |s| s[:body] } + @body
  @snakes_heads_not_my_head, @snakes_bodies_not_my_body = @snakes_heads - [@head], @snakes_bodies - @body
  @food_hazards = @food.select { |f| @hazards.any? { |h| f[:x] == h[:x] && f[:y] == h[:y] } }

  def adjacent_cells(x, y)
    x, y = x.to_i, y.to_i
    [{ x: x - 1, y: y }, { x: x + 1, y: y }, { x: x, y: y - 1 }, { x: x, y: y + 1 }]
  end

  @head_neighbors = adjacent_cells(@head[:x], @head[:y])
  @other_snakes_head_neighbors = @snakes_heads_not_my_head.flat_map { |s| adjacent_cells(s[:x], s[:y]) }
  @shared_neighbors = @head_neighbors & @other_snakes_head_neighbors

  @snakes_info = @snakes.map do |s|
    { id: s[:id], name: s[:name], length: s[:body].length, head: s[:head],
      head_neighbors: adjacent_cells(s[:head][:x], s[:head][:y]) }
  end

  @id = board[:you][:id]
  @shorter_snake_heads = @snakes_heads.select { |h| @snakes.any? { |s| s[:length] < @length && h[:x] == s[:head][:x] && h[:y] == s[:head][:y] } }
  @shared_longer_snakes = @shared_neighbors.select { |s| @snakes.any? { |snake| snake[:length] > @length && s[:x] == snake[:head][:x] && s[:y] == snake[:head][:y] } }
  @shared_shorter_snakes = @shared_neighbors.select { |s| @snakes.any? { |snake| snake[:length] < @length && s[:x] == snake[:head][:x] && s[:y] == snake[:head][:y] } }
  @shared_same_length_snakes = @shared_neighbors.select { |s| @snakes.any? { |snake| snake[:length] == @length && s[:x] == snake[:head][:x] && s[:y] == snake[:head][:y] } }

  # Each time the snake eats a piece of food, its tail grows longer, making the game increasingly difficult.
  # The user controls the direction of the snake's head (up, down, left, or right), and the snake's body follows. The player cannot stop the snake from moving while the game is in progress.
  # The board is a 2-dimensional array of cells, each cell containing a hash with x and y coordinates. The board is of variable size, and is surronded by walls.
  # Other snakes and hazards are present on the board and should be avoided.
  # The board is updated every turn.

  @my_snake = @snakes.select { |s| s[:id] == board[:you][:id] }

  # Function to check if a cell is a wall
  def is_wall?(x, y)
    return false if @game_mode == 'wrapped'
    x.negative? || y.negative? || x > @width || y > @height
  end
  
  def is_snake?(x, y)
    !(@snakes_bodies + @snakes_heads + @body).any? { |c| c[:x] == x && c[:y] == y }
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

  def adjacent_cells(x, y)
    x, y = x.to_i, y.to_i
    [{ x: x - 1, y: y }, { x: x + 1, y: y }, { x: x, y: y - 1 }, { x: x, y: y + 1 }]
  end

  @head_neighbors = adjacent_cells(@head[:x], @head[:y])
  @other_snakes_head_neighbors = @snakes_heads_not_my_head.flat_map { |s| adjacent_cells(s[:x], s[:y]) }
  @shared_neighbors = @head_neighbors & @other_snakes_head_neighbors

  @snakes_info = @snakes.map do |s|
    { id: s[:id], name: s[:name], length: s[:body].length, head: s[:head],
      head_neighbors: adjacent_cells(s[:head][:x], s[:head][:y]) }
  end

  @id = board[:you][:id]
  @shorter_snake_heads = @snakes_heads.select { |h| @snakes.any? { |s| s[:length] < @length && h[:x] == s[:head][:x] && h[:y] == s[:head][:y] } }
  @shared_longer_snakes = @shared_neighbors.select { |s| @snakes.any? { |snake| snake[:length] > @length && s[:x] == snake[:head][:x] && s[:y] == snake[:head][:y] } }
  @shared_shorter_snakes = @shared_neighbors.select { |s| @snakes.any? { |snake| snake[:length] < @length && s[:x] == snake[:head][:x] && s[:y] == snake[:head][:y] } }
  @shared_same_length_snakes = @shared_neighbors.select { |s| @snakes.any? { |snake| snake[:length] == @length && s[:x] == snake[:head][:x] && s[:y] == snake[:head][:y] } }
  @my_snake = @snakes.select { |s| s[:id] == board[:you][:id] }

  # Function to check if a cell is a wall
  def is_wall?(x, y)
    return false if @game_mode == 'wrapped'
    x.negative? || y.negative? || x > @width || y > @height
  end
  
  def is_snake?(x, y)
    !(@snakes_bodies + @snakes_heads + @body).any? { |c| c[:x] == x && c[:y] == y }
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

  def to_i_coords(x1, y1, x2, y2)
    [x1.to_i, y1.to_i, x2.to_i, y2.to_i]
  end

  def direction_between(x1, y1, x2, y2)
    x1, y1, x2, y2 = to_i_coords(x1, y1, x2, y2)
    return 'right' if x1 < x2
    return 'left' if x1 > x2
    return 'up' if y1 < y2
    return 'down' if y1 > y2
  end

  def possible_directions_between(x1, y1, x2, y2)
    x1, y1, x2, y2 = to_i_coords(x1, y1, x2, y2)
    horizontal = x1 < x2 ? 'right' : 'left'
    vertical = y1 < y2 ? 'up' : 'down'
    [horizontal, vertical]
  end

  def opposite_direction(x1, y1, x2, y2)
    direction = direction_between(x1, y1, x2, y2)
    invert_direction(direction)
  end

  def invert_direction(direction)
    { up: :down, down: :up, left: :right, right: :left }.invert[direction]
  end

  def opposite_edge_cell(x, y)
    x, y = to_i_coords(x, y)
    return { x: @width - 1, y: y } if x == 0
    return { x: 0, y: y } if x == @width - 1
    return { x: x, y: @height - 1 } if y == 0
    return { x: x, y: 0 } if y == @height - 1
  end

  # Function to find the neighbors of a given cell x,y coordinates
  def neighbors_of(x, y)
    adjacent_cells(x, y)
  end

  # My tail neighbors are the cells adjacent to my tail
  @my_tail_neighbors = adjacent_cells(@my_tail.first[:x], @my_tail.first[:y])

  # Cell base score
  @cell_base_score = 1000

  # Set score multiplier for each type of cell
  # Load values from included config file
  @score_multiplier = YAML.load_file('config.yml')
  # Pull in values for current game mode
  @score_multiplier.each do |k, v|
    @score_multiplier[k] = v[@game_mode]
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
    elsif collection
      types << type if collection.call(cell[:x], cell[:y])
    end
  end
end

def cell_score(types)
  score = types.any? ? types.map { |type| @score_multiplier[type] || 0 }.reduce(:+) : 0
  score += @cell_base_score
end

def process_cell(cell)
  types = []
  update_types(cell, types)

  x1, y1 = @head[:x], @head[:y]
  x2, y2 = cell[:x], cell[:y]
  
  cell.merge(
    types: types,
    score: cell_score(types),
    direction: direction_between(x1, y1, x2, y2),
    possible_directions: possible_directions_between(x1, y1, x2, y2),
    opposite_direction: opposite_direction(x1, y1, x2, y2),
    neighbors: neighbors_of(x2, y2)
  )
end

@turn_score_array = @board_hash.map { |cell| process_cell(cell) }

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
    @direction_scores = {}
    %w[left right up down].each do |dir|
      @direction_scores[dir] = turn_score_array.select { |cell| cell[:direction] == dir }.map { |cell| cell[:score] }.reduce(:+)
    end
  end
  
  def direction_scores_possible(turn_score_array)
    @direction_scores_possible = {}
    %w[left right up down].each do |dir|
      @direction_scores_possible[dir] = turn_score_array.select { |cell| cell[:possible_directions].include?(dir) }.map { |cell| cell[:score] }.reduce(:+)
    end
  end
  
  def direction_scores_possible_2(turn_score_array)
    @direction_scores_possible_2 = {}
    pairs = [%w[left up], %w[left down], %w[right up], %w[right down]]
    pairs.each do |pair|
      key = pair.join('_')
      @direction_scores_possible_2[key] = turn_score_array.select { |cell| pair.all? { |dir| cell[:possible_directions].include?(dir) } }.map { |cell| cell[:score] }.reduce(:+)
    end
  end  

  @possible_turns = []
  # Select my possible turns from the @turn_score_array. A possible turn is a direction to a head_neighbor that has a score greater than 0.
  @turn_score_array.select { |cell| cell[:types].include?('head_neighbor') && (cell[:score]).positive? }.each do |cell|
    @possible_turns << cell
  end
    
  def process_wrapped_edge(x, y)
    opposite_edge = opposite_edge_cell(x, y)
    @turn_score_array.select { |cell| cell[:x] == opposite_edge[:x] && cell[:y] == opposite_edge[:y] && (cell[:score]).positive? }.each do |cell|
      # invert the direction of the cell
      cell[:direction] = invert_direction(cell[:direction])
      @possible_turns << cell
    end
  end

  if @game_mode == 'wrapped'
    if @head[:x] == 0 || @head[:x] == @width - 1
      process_wrapped_edge(@head[:x], @head[:y])
    elsif @head[:y] == 0 || @head[:y] == @height - 1
      process_wrapped_edge(@head[:x], @head[:y])
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

  # Output the end time in ms
  end_time = Time.now
  puts "End time is: #{end_time} - took #{end_time - start_time} seconds"

  debug = false
  if debug
    puts "Possible moves: #{@possible_moves}\npossible_turns: #{@possible_turns}\nHighest score: #{@highest_score}"
    turn_data = @turn_score_array.group_by { |cell| cell[:types] }.map { |types, cells| [types, cells.count, cells.map { |cell| cell[:score] }.reduce(:+)] }.sort_by { |types, count, score| [count, score] }.reverse
    turn_data.first(5).each { |types, count| puts "Most common #{types} - #{count}" }
    turn_data.last(5).each { |types, count| puts "Least common #{types} - #{count}" }
    scores_data = @turn_score_array.group_by { |cell| cell[:score] }.map { |score, cells| [score, cells.count] }
    scores_data.sort_by(&:first).reverse.first(5).each { |score, count| puts "highest scores #{score} - #{count}" }
    scores_data.sort_by(&:first).first(5).each { |score, count| puts "lowest scores #{score} - #{count}" }
    turn_data.each { |types, count, score| puts "Most common #{types} - #{score}" }
  end

  puts "MOVE: #{@move_direction} - TURN: #{board[:turn]}"
  { "move": @move_direction }
end
