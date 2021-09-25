# frozen_string_literal: true

$VERBOSE = nil
# Health find threshold variable
@@health_threshold = 25

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
  puts "There are the following snakes: #{@snakes}"

  # Puts all the food in an array
  @food = board[:board][:food] || []
  puts "There is food at: #{@food}"

  # Puts all the hazards in an array
  @hazards = board[:board][:hazards] || []
  puts "There are hazards at: #{@hazards}"

  # Puts the snakes length
  @length = board[:you][:length]
  puts "My length is: #{@length}"

  # Puts x, y coordinates hash of all cells on the board
  @board_hash = board[:board][:height].times.map do |i|
    board[:board][:width].times.map do |j|
      { x: j, y: i }
    end
  end.flatten
  # puts "All board cells are at: #{@board_hash}"

  # Puts x, y coordinates hash of my snake's head
  @head = board[:you][:head]
  puts "My head is at: #{@head}"

  # Puts x, y coordinates hash of my snake's body
  @body = board[:you][:body].map { |b| { x: b[:x], y: b[:y] } }.flatten
  puts "My body is at: #{@body}"

  # Puts where all other snakes bodies and heads are
  @snakes_bodies = board[:board][:snakes].map { |s| s[:body] }.flatten + @body || []
  # Remove my body from the list of snakes bodies
  @snakes_bodies.delete_if { |s| s[:id] == board[:you][:id] }

  # Puts where all snakes heads are
  @snakes_heads = board[:board][:snakes].map { |s| s[:head] }.flatten || []
  puts "All snakes heads are at: #{@snakes_heads}"

  # Remove snake heads from the list of snakes bodies
  @snakes_bodies.delete_if { |s| @snakes_heads.include?(s) }

  # Puts where all snakes heads are, but not my head
  @snakes_heads_not_my_head = board[:board][:snakes].map { |s| s[:head] }.flatten - [@head] || []

  # Puts where all food hazards are
  @food_hazards = board[:board][:food] + @hazards || []

  # Function to determine x,y coordinate pair hash of each cell adjacent to the head
  def adjacent_cells(x, y)
    [{ x: x - 1, y: y }, { x: x + 1, y: y }, { x: x, y: y - 1 }, { x: x, y: y + 1 }]
  end

  @head_neighbors = adjacent_cells(@head[:x], @head[:y])

  puts "My head neighbors are: #{@head_neighbors}"

  @other_snakes_head_neighbors = @snakes_heads_not_my_head.map { |s| adjacent_cells(s[:x], s[:y]) }.flatten

  puts "Other snakes head neighbors are: #{@other_snakes_head_neighbors}"

  # Check if any @head_neighbors are in @other_snakes_head_neighbors
  @shared_neighbors = @head_neighbors.select { |h| @other_snakes_head_neighbors.include?(h) }
  puts "Shared neighbors are: #{@shared_neighbors}"

  @possible_moves = []

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
        ['right', 'up']
      elsif y1 > y2
        ['right', 'down']
      end
    elsif x1 > x2
      if y1 < y2
        ['left', 'down']
      elsif y1 > y2
        ['left', 'up']
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

  # Create an array of all cells. Each cell is a hash with x and y coordinates, a type, and the direction of the cell realative to the snake's head.
  # The type of cell is either a wall, a hazard, a food, a food_hazard, a snake body, or a snake head.
  # The direction is the direction of the cell relative to the snake's head.
  turn_array = []
  @board_hash.each do |cell|
    # Check if is a wall
    if is_wall?(cell[:x], cell[:y])
      # Set :score to 0 for walls
      turn_array << { x: cell[:x], y: cell[:y], type: 'wall',
                      direction: direction_between(@head[:x], @head[:y], cell[:x], cell[:y]), both_dirs: possible_directions_between(@head[:x], @head[:y], cell[:x], cell[:y]), score: 0 }
    elsif @food.include?(cell)
      # Set :score to +5 for food
      turn_array << { x: cell[:x], y: cell[:y], type: 'food',
                      direction: direction_between(@head[:x], @head[:y], cell[:x], cell[:y]), both_dirs: possible_directions_between(@head[:x], @head[:y], cell[:x], cell[:y]), score: 30 }
    elsif @snakes_heads.include?(cell)
      # Set :score to -1 for snake heads
      turn_array << { x: cell[:x], y: cell[:y], type: 'snake_head',
                      direction: direction_between(@head[:x], @head[:y], cell[:x], cell[:y]), score: 3 }
    elsif @snakes_bodies.include?(cell)
      # Set :score to -1 for snake bodies
      turn_array << { x: cell[:x], y: cell[:y], type: 'snake_body',
                      direction: direction_between(@head[:x], @head[:y], cell[:x], cell[:y]), score: 2 }
    elsif @hazards.include?(cell)
      # Set :score to -0.5 for hazards
      turn_array << { x: cell[:x], y: cell[:y], type: 'hazard',
                      direction: direction_between(@head[:x], @head[:y], cell[:x], cell[:y]), score: 4 }
    elsif @body.include?(cell)
      turn_array << { x: cell[:x], y: cell[:y], type: 'my_body',
                      direction: direction_between(@head[:x], @head[:y], cell[:x], cell[:y]), score: 3 }
    elsif @corners.include?(cell)
      turn_array << { x: cell[:x], y: cell[:y], type: 'corner',
                      direction: direction_between(@head[:x], @head[:y], cell[:x], cell[:y]), score: 6 }
    elsif @food_hazards.include?(cell)
      turn_array << { x: cell[:x], y: cell[:y], type: 'food_hazard',
                      direction: direction_between(@head[:x], @head[:y], cell[:x], cell[:y]), score: 10 }
    elsif @shared_neighbors.include?(cell)
      turn_array << { x: cell[:x], y: cell[:y], type: 'shared_neighbor',
                      direction: direction_between(@head[:x], @head[:y], cell[:x], cell[:y]), score: 6 }
    else # is empty
      turn_array << { x: cell[:x], y: cell[:y], type: 'empty',
                      direction: direction_between(@head[:x], @head[:y], cell[:x], cell[:y]), score: 25 }
    end
  end
   #puts "Turn array is: #{turn_array}"

  # For each direction, find the number of empty or food cells in that direction, and the total score of all cells in that direction
  # takes the @turn_array as input
  def direction_scores(turn_array)
    # Create a hash of all the directions and the number of times they appear
    @direction_scores = Hash.new(0)
    turn_array.each do |cell|
      if cell[:type] == 'empty' || cell[:type] == 'food'
        # Add 5 to the score for food cells
        @direction_scores[cell[:direction]] += 5
      end
    end
    # Return the most common directions and their scores
    @direction_scores
  end

  @possible_turns = []
  # For each head_neighbor, inspect the corresponding cell in turn_array and output the results
  @head_neighbors.each do |head_neighbor|
    turn_array.each do |turn|
      next unless head_neighbor[:x] == turn[:x] && head_neighbor[:y] == turn[:y]

      puts "Possible turn is: #{turn}"
      # Add entire turn array to a new array of possible_turns
      @possible_turns << turn
      case turn[:type]
      when 'occupied'
        @possible_moves.delete(turn[:direction])
      when 'wall'
        @possible_moves.delete(turn[:direction])
      when 'snake_head'
        @possible_moves.delete(turn[:direction])
      when 'snake_body'
        @possible_moves.delete(turn[:direction])
      when 'my_body'
        @possible_moves.delete(turn[:direction])
      when 'food'
        # Add the direction to the @possible_moves array
        @possible_moves << turn[:direction]
      when 'empty'
        # Add the direction to the @possible_moves array
        @possible_moves << turn[:direction]
      when 'corner'
        # Add the direction to the @possible_moves array
        @possible_moves << turn[:direction]
      when 'food_hazard'
        # Add the direction to the @possible_moves array
        @possible_moves << turn[:direction]
      when 'hazard'
        # Add the direction to the @possible_moves array
        @possible_moves << turn[:direction]
      end
    end
  end



  # If head is at edge of board, then remove the direction from @possible_moves
  @possible_moves.delete('left') if (@head[:x]).zero?
  @possible_moves.delete('right') if @head[:x] == @width
  @possible_moves.delete('down') if (@head[:y]).zero?
  @possible_moves.delete('up') if @head[:y] == @height
  
  # Once our snake's length is greater than that of any other snake.
  # then we need to find the direction of the nearest snake's head and set @move_direction to that direction if it is in @possible_moves
  @snakes.each do |snake|
    if snake[:id] != @id
      if snake[:length] < (@length)
        puts "Largest other snake is: #{snake[:name]} whos length is: #{snake[:length]} - my length is: #{@length}"
        # Find x and y coordinates of head of other snake
        other_head_x = snake[:head][:x]
        other_head_y = snake[:head][:y]
        # Get the direction of the head of the other snake
        other_head_direction = direction_between(@head[:x], @head[:y], other_head_x, other_head_y)
        # If the other_head_direction is in @possible_moves, then set @move_direction to that direction
        if @possible_moves.include?(other_head_direction)
          # Increase the score of the dicrection in the @possible_turns array by 10
          @possible_turns.each do |turn|
            if turn[:direction] == other_head_direction
              turn[:score] += 10
              turn[:type] = 'shared_neighbor_shorter'
            end
          end

          puts "Moving to eat other snake - #{other_head_direction}"
          @move_direction = other_head_direction
        end
      # If there is another longer snake, set @@health_threshold to X
      elsif snake[:length] > @length
        @@health_threshold = 100
        puts "Longer snake exists - lets eat more food! - health threshold is: #{@@health_threshold}"
        puts "Largest other snake is: #{snake[:name]} whos length is: #{snake[:length]} - my length is: #{@length}"
      # If all snakes are shorter than our snake, decrease health_threshold by 10
      else
        @@health_threshold -= 10
        # Clamp health_threshold to a minimum of 30
        @@health_threshold = 30 if @@health_threshold < 30
        puts "We are the biggest - Decreasing health threshold - health threshold is: #{@@health_threshold}"
        puts "Largest other snake is: #{snake[:name]} whos length is: #{snake[:length]} - my length is: #{@length}"
      end
    end
  end

  
  # If top score direction is a possible move, then increase the score of that direction in the @possible_turns by 10
  if @possible_moves.include?(@top_score_direction)
    puts "Top score direction is a possible move!"
    @possible_turns.each do |turn|
      if turn[:direction] == @top_score_direction
        turn[:score] += 10
        turn[:type] = 'top_score'
        puts "Top score direction is: #{@top_score_direction}!"
      end
    end
  end

  # Select higest score object from possible_turns array
  @highest_score = @possible_turns.max_by { |turn| turn[:score] }

  # Set @move_direction to the direction of the highest score object
  @move_direction = @highest_score[:direction]

  puts "possible_turns are: #{@possible_turns}"
  puts "Possible moves are: #{@possible_moves}"

  # If the @highest_score[:direction] is not in @possible_moves, then remove from @possible_turns
  unless @possible_moves.include?(@highest_score[:direction])
    @possible_turns.delete(@highest_score)
    puts '--- High score move not possible!'

    # Select next highest score object from possible_turns array
    @highest_score = @possible_turns.max_by { |turn| turn[:score] }
   puts "--- Next best score is: #{@highest_score}"

    # set @move_direction to the direction of the next highest score object
    @move_direction = @highest_score[:direction]
  end


    # If our health drops below 50, find direction of the nearest food and set @move_direction to that direction
    @health = board[:you][:health]
    if @health < @@health_threshold
      @record_low_health = @health
      puts "Health is: #{@health}!! Finding food"
      turn_array.each do |turn|
        if turn[:type] == 'food' && @possible_moves.include?(turn[:direction])
          # If the direction of the food is in @possible_moves, then increase the score of that direction in the @possible_turns by 100
          @possible_turns.each do |turn|
            if turn[:direction] == turn[:direction]
              turn[:score] += 100
              turn[:type] = 'required_food'
            end
          end
        end
      end
      # if @health is still below @@health_threshold, increase the @@health_threshold
      if @health < @@health_threshold
        @@health_threshold += 1
        puts "Health threshold is now: #{@@health_threshold}"
      end
    end

  # Once we have a snake length of greater than board width or height
  # then we need to start trying to move to the center of the board
  if @length > @width * 3 || @length > @height * 3
    puts "Snake length is: #{@length}!! Finding center"
    # Find x and y coordinates of center of board
    center_x = @width / 2
    center_y = @height / 2
    # Get the direction of the center of the board
    center_direction = direction_between(@head[:x], @head[:y], center_x.round, center_y.round)

    # If the center_direction is in @possible_moves, then set @move_direction to that direction
    @move_direction = center_direction if @possible_moves.include?(center_direction)
    puts "Moving to center - #{center_direction}"
  end

  # If hazards are in my head_neighbors array, then attempt to move to the center_direction
  if @head_neighbors.include?('hazard')
    puts 'Hazard in my head_neighbors array!! Finding center'
    # Find x and y coordinates of center of board
    center_x = @width / 2
    center_y = @height / 2
    # Get the direction of the center of the board
    center_direction = direction_between(@head[:x], @head[:y], center_x.round, center_y.round)

    # If the center_direction is in @possible_moves, then set @move_direction to that direction
    @move_direction = center_direction if @possible_moves.include?(center_direction)
    puts "Moving to center - #{center_direction}"
  end

  puts "Highest score is: #{@highest_score}"
  # Return the most common direction of empty cells and food cells
  @direction_best_scores = direction_scores(turn_array)
  puts "Direction best scores are: #{@direction_best_scores}"
  
  # Top scoring direction based on value of @direction_best_scores
  @top_score_direction = @direction_best_scores.select { |k, v| v == @direction_best_scores.values.max }.keys.first
  puts "Top score direction is: #{@top_score_direction}"

  # Second highest scoring direction from direction_scores(turn_array)
  @second_score_direction = @direction_best_scores.select { |k, v| v == @direction_best_scores.values.max(2).min }.keys.first
  puts "Second score direction is: #{@second_score_direction}"

  # If the top score direction is in @possible_moves, then go to that direction, otherwise go to the second highest score direction
  if @possible_moves.include?(@top_score_direction)
    puts "Top score direction is a possible move!"
    @move_direction = @top_score_direction
  elsif @possible_moves.include?(@second_highest_score_direction)
    puts "Second highest score direction is a possible move!"
    @move_direction = @second_highest_score_direction
  end


  # Output the end time
  end_time = Time.now
  puts "End time is: #{end_time} - took #{end_time - start_time} seconds"
  puts "MOVE: #{@move_direction}"
  { "move": @move_direction }
end
