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
  # creat an array of all the other snakes bodies
  @mybody = board[:you][:body]
  @snakes_bodies_not_my_body = board[:board][:snakes].map { |s| s[:body] }.flatten - @mybody - @snakes_heads_not_my_head || []
  @other_snakes_head_neighbors = @snakes_heads_not_my_head.map { |s| adjacent_cells(s[:x], s[:y]) }.flatten
  @other_snakes_body_neighbors = @snakes_bodies_not_my_body.map { |s| adjacent_cells(s[:x], s[:y]) }.flatten
  # Check if any @head_neighbors are in @other_snakes_head_neighbors
  @shared_neighbors = @head_neighbors.select { |h| @other_snakes_head_neighbors.include?(h) }
  @shared_neighbors_body = @head_neighbors.select { |h| @other_snakes_body_neighbors.include?(h) }
  @possible_moves_score = {"left" => 0, "right" => 0, "up" => 0, "down" => 0}
  # Create an array that contains all the boards corners.
  @corners = [{ x: 0, y: 0 }, { x: 0, y: bheight - 1 }, { x: bwidth - 1, y: 0 }, { x: bwidth - 1, y: bheight - 1 }]
  # Crearte an array that contains all the other snakes and their length.

  

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

  

  # Avoid yourself by removing move from possible moves if the snake body is part is one position away from the head.
  body.each do |body_part|
    if xhead - 1 == body_part[:x].to_i && yhead == body_part[:y].to_i
      @possible_moves_score["left"] -= 2
    end
    if xhead + 1 == body_part[:x].to_i && yhead == body_part[:y].to_i
      @possible_moves_score["right"] -= 2
    end
    if yhead - 1 == body_part[:y].to_i && xhead == body_part[:x].to_i
      @possible_moves_score["down"] -= 2
    end
    if yhead + 1 == body_part[:y].to_i && xhead == body_part[:x].to_i
      @possible_moves_score["up"] -= 2
    end
  end

  body.each do |body_part|
    if xhead - 2 == body_part[:x].to_i && yhead == body_part[:y].to_i
      @possible_moves_score["left"] -= 1
    end
    if xhead + 2 == body_part[:x].to_i && yhead == body_part[:y].to_i
      @possible_moves_score["right"] -= 1
    end
    if yhead - 2 == body_part[:y].to_i && xhead == body_part[:x].to_i
      @possible_moves_score["down"] -= 1
    end
    if yhead + 2 == body_part[:y].to_i && xhead == body_part[:x].to_i
      @possible_moves_score["up"] -= 1
    end
  end

  body.each do |body_part|
    if xhead - 3 == body_part[:x].to_i && yhead == body_part[:y].to_i
      @possible_moves_score["left"] -= 0.5
    end
    if xhead + 3 == body_part[:x].to_i && yhead == body_part[:y].to_i
      @possible_moves_score["right"] -= 0.5
    end
    if yhead - 3 == body_part[:y].to_i && xhead == body_part[:x].to_i
      @possible_moves_score["down"] -= 0.5
    end
    if yhead + 3 == body_part[:y].to_i && xhead == body_part[:x].to_i
      @possible_moves_score["up"] -= 0.5
    end
  end

  # Avoid other snakes by removing move from possible moves if the snake body is part is one position away from the head.
  snakes = board[:board][:snakes]
  # Remove yourslef from list of snakes. We avoid ourselvs already above.
  snakes.delete(board[:you])

  snakes.each do |snake|
    snake[:body].each do |body_part|
      if xhead - 1 == body_part[:x].to_i && yhead == body_part[:y].to_i
        @possible_moves_score["left"] -= 0.8
      end
      if xhead + 1 == body_part[:x].to_i && yhead == body_part[:y].to_i
        @possible_moves_score["right"] -= 0.8
      end
      if yhead - 1 == body_part[:y].to_i && xhead == body_part[:x].to_i
        @possible_moves_score["down"] -= 0.8
      end
      if yhead + 1 == body_part[:y].to_i && xhead == body_part[:x].to_i
        @possible_moves_score["up"] -= 0.8
      end
    end
  end

  snakes.each do |snake|
    snake[:body].each do |body_part|
      if xhead - 2 == body_part[:x].to_i && yhead == body_part[:y].to_i
        @possible_moves_score["left"] -= 0.7
      end
      if xhead + 2 == body_part[:x].to_i && yhead == body_part[:y].to_i
        @possible_moves_score["right"] -= 0.7
      end
      if yhead - 2 == body_part[:y].to_i && xhead == body_part[:x].to_i
        @possible_moves_score["down"] -= 0.7
      end
      if yhead + 2 == body_part[:y].to_i && xhead == body_part[:x].to_i
        @possible_moves_score["up"] -= 0.7
      end
    end
  end

  # Put shared snake body neighbors in the corners array.
  puts "These are the snakes head neighbors: #{@head_neighbors}"
  puts "These are the cells next to a snakes body: #{@shared_neighbors_body}"

  # Reduce score for moves for cells shared by neighbors body.
  @shared_neighbors_body.each do |cell|
    if cell[:x] == xhead - 1 && cell[:y] == yhead
      @possible_moves_score["left"] -= 0.1
    end
    if cell[:x] == xhead + 1 && cell[:y] == yhead
      @possible_moves_score["right"] -= 0.1
    end
    if cell[:y] == yhead - 1 && cell[:x] == xhead
      @possible_moves_score["down"] -= 0.1
    end
    if cell[:y] == yhead + 1 && cell[:x] == xhead
      @possible_moves_score["up"] -= 0.1
    end
  end
  @shared_neighbors_body.each do |cell|
    if cell[:x] == xhead - 2 && cell[:y] == yhead
      @possible_moves_score["left"] -= 0.1
    end
    if cell[:x] == xhead + 2 && cell[:y] == yhead
      @possible_moves_score["right"] -= 0.1
    end
    if cell[:y] == yhead - 2 && cell[:x] == xhead
      @possible_moves_score["down"] -= 0.1
    end
    if cell[:y] == yhead + 2 && cell[:x] == xhead
      @possible_moves_score["up"] -= 0.1
    end
  end

 
  # Avoid moving into a cell where the snakes head is one position away from a neighboring cell.
  if @shared_neighbors.length > 0
    @shared_neighbors.each do |s|
      if xhead - 1 == s[:x].to_i && yhead == s[:y].to_i && xhead != 0
        @possible_moves_score["left"] -= 1
      end
      # add back to score if that space is occupied by a snake shorter than you
      if xhead + 1 == s[:x].to_i && yhead == s[:y].to_i && xhead != bwidth - 1
        @possible_moves_score["right"] -= 1
      end
      if yhead - 1 == s[:y].to_i && xhead == s[:x].to_i && yhead != 0
        @possible_moves_score["down"] -= 1
      end
      if yhead + 1 == s[:y].to_i && xhead == s[:x].to_i && yhead != bheight - 1
        @possible_moves_score["up"] -= 1
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

# create an array of food locations on the board.
  
  @food_cells = board[:board][:food].map { |b| { x: b[:x], y: b[:y] } }.flatten
  puts "food: #{@food_cells}"
  @health = board[:you][:health]

 if @food_cells.length > 0
  # prefer to move to it over the other possible moves
  @food_cells.each do |food|
    if xhead - 1 == food[:x].to_i && yhead == food[:y].to_i && xhead != 0 && @shared_neighbors.exclude?(food)
      @possible_moves_score["left"] += 0.5
    end
    if xhead + 1 == food[:x].to_i && yhead == food[:y].to_i && xhead != bwidth - 1 && @shared_neighbors.exclude?(food)
      @possible_moves_score["right"] += 0.5
    end
    if yhead - 1 == food[:y].to_i && xhead == food[:x].to_i && yhead != 0 && @shared_neighbors.exclude?(food)
      @possible_moves_score["down"] += 0.5
    end
    if yhead + 1 == food[:y].to_i && xhead == food[:x].to_i && yhead != bheight - 1 && @shared_neighbors.exclude?(food)
      @possible_moves_score["up"] += 0.5
    end
  end
end
if @food_cells.length > 0
  # prefer to move to it over the other possible moves
  @food_cells.each do |food|
    if xhead - 2 == food[:x].to_i && yhead == food[:y].to_i && xhead != 0
      @possible_moves_score["left"] += 0.2
    end
    if xhead + 2 == food[:x].to_i && yhead == food[:y].to_i && xhead != bwidth - 1
      @possible_moves_score["right"] += 0.2
    end
    if yhead - 2 == food[:y].to_i && xhead == food[:x].to_i && yhead != 0
      @possible_moves_score["down"] += 0.2
    end
    if yhead + 2 == food[:y].to_i && xhead == food[:x].to_i && yhead != bheight - 1
      @possible_moves_score["up"] += 0.2
    end
  end
end

if @health < 50
  closest_food = @food_cells.min_by { |food| (food[:x] - xhead).abs + (food[:y] - yhead).abs }
  puts "closest food: #{closest_food}"
  # move snake towards closest food. If xhead is less than closest food x, move right. If xhead is greater than closest food x, move left. 
  # If yhead is less than closest food y, move down. If yhead is greater than closest food y, move up
  if xhead < closest_food[:x]
    @possible_moves_score["right"] += 0.5
  end
  if xhead > closest_food[:x]
    @possible_moves_score["left"] += 0.5
  end
  if yhead < closest_food[:y]
    @possible_moves_score["down"] += 0.5
  end
  if yhead > closest_food[:y]
    @possible_moves_score["up"] += 0.5
  end
end

# reduces score of moves that are a wall cell. 
  @possible_moves_score.each do |key, value|
    if key == "left" && xhead - 2 == 0
      @possible_moves_score["left"] -= 0.1
    end
    if key == "right" && xhead + 2 == bwidth - 1
      @possible_moves_score["right"] -= 0.1
    end
    if key == "down" && yhead - 2 == 0
      @possible_moves_score["down"] -= 0.1
    end
    if key == "up" && yhead + 2 == bheight - 1
      @possible_moves_score["up"] -= 0.1
    end
  end

puts "possible moves: #{@possible_moves_score}"
# if there are multiple possible moves, choose the one that moves away from the wall.
  if @possible_moves_score.length > 1
    @possible_moves_score.each do |key, value|
      if key == "left" && xhead < (bwidth / 2) - 1
        @possible_moves_score["left"] -= 0.1
      end
      if key == "right" && xhead > (bwidth / 2) + 1
        @possible_moves_score["right"] -= 0.1
      end
      if key == "down" && yhead < (bheight / 2) - 1
        @possible_moves_score["down"] -= 0.1
      end
      if key == "up" && yhead > (bheight / 2) + 1
        @possible_moves_score["up"] -= 0.1
      end
    end
  end

@mylength = board[:you][:body].length
# Check if there is another snake within one cells of own head.
  snakes.each do |snake|
    puts "snake: #{snake}"
    puts snake[:head][:x]
    puts snake[:head][:y]
    puts @myhead
    if snake[:length] < @mylength
      puts "There is a smaller snake around"
        if xhead - 2 == snake[:head][:x].to_i && yhead == snake[:head][:y].to_i && xhead != 0
          puts "move left to try and eat smaller snake"
          @possible_moves_score["left"] += 0.7
        end
        if xhead + 2 == snake[:head][:x].to_i && yhead == snake[:head][:y].to_i && xhead != bwidth - 1
          puts "move right to try and eat smaller snake"
          @possible_moves_score["right"] += 0.7
        end
        if yhead - 2 == snake[:head][:y].to_i && xhead == snake[:head][:x].to_i && yhead != 0
          puts "move down to try and eat smaller snake"
          @possible_moves_score["down"] += 0.7
        end
        if yhead + 2 == snake[:head][:y].to_i && xhead == snake[:head][:x].to_i && yhead != bheight - 1
          puts "move up to try and eat smaller snake"
          @possible_moves_score["up"] += 0.7
        end
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