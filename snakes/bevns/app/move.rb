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
  # Sets up an array that contains each of the possible moves at the start of the turn. We'll remove turns when they are no valid.
  possible_moves = ["up", "down", "left", "right"]
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

  # Avoid walls by looking at X and Y positions. If the snake is on the edge of the board, move away from the wall. 
  # Remove move from possible moves if at the edge of the board. 
  if xhead == 0
    possible_moves.delete("left")
  end
  if xhead == bwidth - 1
    possible_moves.delete("right")
  end
  if yhead == 0
    possible_moves.delete("down")
  end
  if yhead == bheight - 1
    possible_moves.delete("up")  
  end

  # Avoid yourself by removing move from possible moves if the snake body is part is one position away from the head.
  body.each do |body_part|
    if xhead - 1 == body_part[:x].to_i && yhead == body_part[:y].to_i
      possible_moves.delete("left")
    elsif xhead + 1 == body_part[:x].to_i && yhead == body_part[:y].to_i
      possible_moves.delete("right")
    elsif yhead - 1 == body_part[:y].to_i && xhead == body_part[:x].to_i
      possible_moves.delete("down")
    elsif yhead + 1 == body_part[:y].to_i && xhead == body_part[:x].to_i
      possible_moves.delete("up")
    end
  end

  # Avoid other snakes by removing move from possible moves if the snake body is part is one position away from the head.
  snakes = board[:board][:snakes]
  # Remove yourslef from list of snakes. We avoid ourselvs already above.
  snakes.delete(board[:you])

  snakes.each do |snake|
    snake[:body].each do |body_part|
      if xhead - 1 == body_part[:x].to_i && yhead == body_part[:y].to_i
        possible_moves.delete("left")
      elsif xhead + 1 == body_part[:x].to_i && yhead == body_part[:y].to_i
        possible_moves.delete("right")
      elsif yhead - 1 == body_part[:y].to_i && xhead == body_part[:x].to_i
        possible_moves.delete("down")
      elsif yhead + 1 == body_part[:y].to_i && xhead == body_part[:x].to_i
        possible_moves.delete("up")
      end
    end
  end
  
  # Avoid moving into a cell where the snakes head is one position away from a neighboring cell.
  if @shared_neighbors.length > 0
    @shared_neighbors.each do |s|
      if xhead - 1 == s[:x].to_i && yhead == s[:y].to_i && xhead != 0 && possible_moves.length > 1
        possible_moves.delete("left")
      elsif xhead + 1 == s[:x].to_i && yhead == s[:y].to_i && xhead != bwidth - 1 && possible_moves.length > 1
        possible_moves.delete("right")
      elsif yhead - 1 == s[:y].to_i && xhead == s[:x].to_i && yhead != 0 && possible_moves.length > 1
        possible_moves.delete("down")
      elsif yhead + 1 == s[:y].to_i && xhead == s[:x].to_i && yhead != bheight - 1 && possible_moves.length > 1
        possible_moves.delete("up")
      end
    end
  end

  # Avoid hazards by removing move from possible moves if hazard near by.
  if gamemode == "royale"
  hazards.each do |hazard|
      if xhead - 1 == hazard[:x].to_i && yhead == hazard[:y].to_i && xhead != 0 && possible_moves.length > 1
        possible_moves.delete("left")
      elsif xhead + 1 == hazard[:x].to_i && yhead == hazard[:y].to_i && xhead != bwidth - 1 && possible_moves.length > 1
        possible_moves.delete("right")
      elsif yhead - 1 == hazard[:y].to_i && xhead == hazard[:x].to_i && yhead != 0 && possible_moves.length > 1
        possible_moves.delete("down")
      elsif yhead + 1 == hazard[:y].to_i && xhead == hazard[:x].to_i && yhead != bheight - 1 && possible_moves.length > 1
        possible_moves.delete("up")
      end
    end
  end

 move = possible_moves.sample
 {"move": move}

end
