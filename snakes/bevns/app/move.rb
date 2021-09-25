# This function is called on every turn of a game. It's how your Battlesnake decides where to move.
# Valid moves are "up", "down", "left", or "right".
# TODO: Use the information in board to decide your next move.
def move(board)
  # Sets our head to a variable we can use elsewhere and converts it to an integer.
  xhead = board[:you][:head][:x].to_i
  yhead = board[:you][:head][:y].to_i
  # Sets the board height and width to an integer so we can use it later. 
  bheight = board[:board][:height].to_i
  bwidth = board[:board][:width].to_i
  # Creates a variable that contains the cordinates of the food. 
  food = board[:board][:food]
  # Creates a variable that contains the cordinates of the food. 
  hazards = board[:board][:hazards]
  #This is our full body. It contains all the snakes body parts.
  fullbody = board[:you][:body]
  #This is our body without the tail. We use this to check if we are going to collide with ourself. The tail will move one position with the head.
  #This works until the snake eats food. Then the tail will stay where it is.
  body = board[:you][:body][0..-2]
  # This is our tails. 
  tail = board[:you][:body][-1]
  # This is the game mode.
  gamemode = board[:game][:ruleset][:name] 
  #create a couple arrays to store hazards and myhead.
  @hazards = board[:board][:hazards].map { |b| { x: b[:x], y: b[:y] } }.flatten
  @myhead = board[:you][:head]  
  # Function to determine x,y coordinate pair hash of each cell adjacent to the head
  def adjacent_cells(x, y)
    [{ x: x - 1, y: y }, { x: x + 1, y: y }, { x: x, y: y - 1 }, { x: x, y: y + 1 }]
  end
  # Find out if the head is adjacent to any cells I am next to.
  @head_neighbors = adjacent_cells(@myhead[:x], @myhead[:y])
  # Create an array of all the other snakes heads
  @snakes_heads_not_my_head = board[:board][:snakes].map { |s| s[:head] }.flatten - [@myhead] || []
  @other_snakes_head_neighbors = @snakes_heads_not_my_head.map { |s| adjacent_cells(s[:x], s[:y]) }.flatten
  # Check if any @head_neighbors are in @other_snakes_head_neighbors
  @shared_neighbors = @head_neighbors.select { |h| @other_snakes_head_neighbors.include?(h) }
  @possible_moves_score = {"left" => 0, "right" => 0, "up" => 0, "down" => 0}
  # Create an array that contains all the boards corners.
  @corners = [{ x: 0, y: 0 }, { x: 0, y: bheight - 1 }, { x: bwidth - 1, y: 0 }, { x: bwidth - 1, y: bheight - 1 }]
  

  # Avoid walls by looking at X and Y positions. If the snake is on the edge of the board, move away from the wall. 
  # Remove move from possible moves if at the edge of the board. 
  if xhead == 0
    # reduce the left key in possible moves score by 1
    @possible_moves_score["left"] -= 2
  end
  if xhead == bwidth - 1
    # reduce the right key in possible moves score by 1
    @possible_moves_score["right"] -= 2
  end
  if yhead == 0
    # reduce the up key in possible moves score by 1
    @possible_moves_score["down"] -= 2
  end
  if yhead == bheight - 1
    # reduce the down key in possible moves score by 1
    @possible_moves_score["up"] -= 2
  end

  puts "possible moves: #{@possible_moves_score}"

  # Avoid yourself by removing move from possible moves if the snake body is part is one position away from the head.
  body.each do |body_part|
    if xhead - 1 == body_part[:x].to_i && yhead == body_part[:y].to_i
      @possible_moves_score["left"] -= 1
    end
    if xhead + 1 == body_part[:x].to_i && yhead == body_part[:y].to_i
      @possible_moves_score["right"] -= 1
    end
    if yhead - 1 == body_part[:y].to_i && xhead == body_part[:x].to_i
      @possible_moves_score["down"] -= 1
    end
    if yhead + 1 == body_part[:y].to_i && xhead == body_part[:x].to_i
      @possible_moves_score["up"] -= 1
    end
  end

  body.each do |body_part|
    if xhead - 2 == body_part[:x].to_i && yhead == body_part[:y].to_i
      @possible_moves_score["left"] -= 0.9
    end
    if xhead + 2 == body_part[:x].to_i && yhead == body_part[:y].to_i
      @possible_moves_score["right"] -= 0.9
    end
    if yhead - 2 == body_part[:y].to_i && xhead == body_part[:x].to_i
      @possible_moves_score["down"] -= 0.9
    end
    if yhead + 2 == body_part[:y].to_i && xhead == body_part[:x].to_i
      @possible_moves_score["up"] -= 0.9
    end
  end

  body.each do |body_part|
    if xhead - 3 == body_part[:x].to_i && yhead == body_part[:y].to_i
      @possible_moves_score["left"] -= 0.8
    end
    if xhead + 3 == body_part[:x].to_i && yhead == body_part[:y].to_i
      @possible_moves_score["right"] -= 0.8
    end
    if yhead - 3 == body_part[:y].to_i && xhead == body_part[:x].to_i
      @possible_moves_score["down"] -= 0.8
    end
    if yhead + 3 == body_part[:y].to_i && xhead == body_part[:x].to_i
      @possible_moves_score["up"] -= 0.8
    end
  end

  # Avoid other snakes by removing move from possible moves if the snake body is part is one position away from the head.
  snakes = board[:board][:snakes]
  # Remove yourslef from list of snakes. We avoid ourselvs already above.
  snakes.delete(board[:you])

  snakes.each do |snake|
    snake[:body].each do |body_part|
      if xhead - 1 == body_part[:x].to_i && yhead == body_part[:y].to_i
        @possible_moves_score["left"] -= 1
      end
      if xhead + 1 == body_part[:x].to_i && yhead == body_part[:y].to_i
        @possible_moves_score["right"] -= 1
      end
      if yhead - 1 == body_part[:y].to_i && xhead == body_part[:x].to_i
        @possible_moves_score["down"] -= 1
      end
      if yhead + 1 == body_part[:y].to_i && xhead == body_part[:x].to_i
        @possible_moves_score["up"] -= 1
      end
    end
  end

  snakes.each do |snake|
    snake[:body].each do |body_part|
      if xhead - 2 == body_part[:x].to_i && yhead == body_part[:y].to_i
        @possible_moves_score["left"] -= 0.9
      end
      if xhead + 2 == body_part[:x].to_i && yhead == body_part[:y].to_i
        @possible_moves_score["right"] -= 0.9
      end
      if yhead - 2 == body_part[:y].to_i && xhead == body_part[:x].to_i
        @possible_moves_score["down"] -= 0.9
      end
      if yhead + 2 == body_part[:y].to_i && xhead == body_part[:x].to_i
        @possible_moves_score["up"] -= 0.9
      end
    end
  end
 
  # Avoid moving into a cell where the snakes head is one position away from a neighboring cell.
  if @shared_neighbors.length > 0
    @shared_neighbors.each do |s|
      if xhead - 1 == s[:x].to_i && yhead == s[:y].to_i && xhead != 0
        @possible_moves_score["left"] -= 0.5
      end
      if xhead + 1 == s[:x].to_i && yhead == s[:y].to_i && xhead != bwidth - 1
        @possible_moves_score["right"] -= 0.5
      end
      if yhead - 1 == s[:y].to_i && xhead == s[:x].to_i && yhead != 0
        @possible_moves_score["down"] -= 0.5
      end
      if yhead + 1 == s[:y].to_i && xhead == s[:x].to_i && yhead != bheight - 1
        @possible_moves_score["up"] -= 0.5
      end
    end
  end

  # Avoid hazards by removing move from possible moves if hazard near by.
  if gamemode == "royale"
  hazards.each do |hazard|
      if xhead - 1 == hazard[:x].to_i && yhead == hazard[:y].to_i && xhead != 0
        @possible_moves_score["left"] -= 0.3
      end
      if xhead + 1 == hazard[:x].to_i && yhead == hazard[:y].to_i && xhead != bwidth - 1
        @possible_moves_score["right"] -= 0.3
      end
      if yhead - 1 == hazard[:y].to_i && xhead == hazard[:x].to_i && yhead != 0
        @possible_moves_score["down"] -= 0.3
      end
      if yhead + 1 == hazard[:y].to_i && xhead == hazard[:x].to_i && yhead != bheight - 1
        @possible_moves_score["up"] -= 0.3
      end
    end
  end

  if gamemode == "royale"
    hazards.each do |hazard|
        if xhead - 2 == hazard[:x].to_i && yhead == hazard[:y].to_i && xhead != 0
          @possible_moves_score["left"] -= 0.2
        end
        if xhead + 2 == hazard[:x].to_i && yhead == hazard[:y].to_i && xhead != bwidth - 1
          @possible_moves_score["right"] -= 0.2
        end
        if yhead - 2 == hazard[:y].to_i && xhead == hazard[:x].to_i && yhead != 0
          @possible_moves_score["down"] -= 0.2
        end
        if yhead + 2 == hazard[:y].to_i && xhead == hazard[:x].to_i && yhead != bheight - 1
          @possible_moves_score["up"] -= 0.2
        end
      end
    end

  # Avoid corners by removing move from possible moves if corner near by.
  @corners.each do |corner|
    if xhead - 2 == corner[:x].to_i && yhead == corner[:y].to_i && xhead != 0
      @possible_moves_score["left"] -= 0.1
    end
    if xhead + 2 == corner[:x].to_i && yhead == corner[:y].to_i && xhead != bwidth - 1
      @possible_moves_score["right"] -= 0.1
    end
    if yhead - 2 == corner[:y].to_i && xhead == corner[:x].to_i && yhead != 0
      @possible_moves_score["down"] -= 0.1
    end
    if yhead + 2 == corner[:y].to_i && xhead == corner[:x].to_i && yhead != bheight - 1
      @possible_moves_score["up"] -= 0.1
    end
  end


 # sort the possible moves by score  
 @highscore_move = @possible_moves_score.select {|x,i| i == @possible_moves_score.values.max }.keys
 #move = possible_moves.sample
 move = @highscore_move.sample
 puts "possible move score: #{@possible_moves_score}"
 puts "highest score move: #{@highscore_move}"
 # puts turn from game board
 puts "Turn: " + board[:turn].to_s
 puts "move: #{move}"
 {"move": move}

end
