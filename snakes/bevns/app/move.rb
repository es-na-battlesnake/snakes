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


  # Avoid walls by looking at X and Y positions. If the snake is on the edge of the board, move away from the wall. 
  # Remove move from possible moves if at the edge of the board. 
  if xhead == 0
    puts "removing left"
    possible_moves.delete("left")
  end
  if xhead == bwidth - 1
    puts "removing right"
    possible_moves.delete("right")
  end
  if yhead == 0
    puts "removing down"
    possible_moves.delete("down")
  end
  if yhead == bheight - 1
    puts "removing up"
    possible_moves.delete("up")  
  end

  # Avoid yourself by removing move from possible moves if the snake body is part is one position away from the head.
  # This is a very simple way to avoid yourself.
  # To-do: Remove entirely
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
  # This is actually looking at other snakes and yourself. I could probably just use this as avoid yourself and other snakes.
  # The difference here is that we are looking at all the snakes which includes our own snake.   
  board[:board][:snakes].each do |body|
    body[:body].each do |body_part|
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

  # Avoid hazards by removing move from possible moves if hazard near by.
  if gamemode == "royale"
  hazards.each do |hazard|
      if xhead - 1 == hazard[:x].to_i && yhead == hazard[:y].to_i && xhead != 0 && possible_moves.length > 1
        puts "Avoiding left hazard"
        possible_moves.delete("left")
      elsif xhead + 1 == hazard[:x].to_i && yhead == hazard[:y].to_i && xhead != bwidth - 1 && possible_moves.length > 1
        puts "Avoiding right hazard"
        possible_moves.delete("right")
      elsif yhead - 1 == hazard[:y].to_i && xhead == hazard[:x].to_i && yhead != 0 && possible_moves.length > 1
        puts "Avoiding down hazard"
        possible_moves.delete("down")
      elsif yhead + 1 == hazard[:y].to_i && xhead == hazard[:x].to_i && yhead != bheight - 1 && possible_moves.length > 1
        puts "Avoiding up hazard"
        possible_moves.delete("up")
      end
    end
  end



  # Avoid food by removing move from possible moves if the snake is one position away from the food.
  if board[:you][:health] > 50 
  food.each do |food_part|
      if xhead - 1 == food_part[:x].to_i && yhead == food_part[:y].to_i && xhead != 0 && possible_moves.length > 1
        possible_moves.delete("left")
      elsif xhead + 1 == food_part[:x].to_i && yhead == food_part[:y].to_i && xhead != bwidth - 1 && possible_moves.length > 1
        possible_moves.delete("right")
      elsif yhead - 1 == food_part[:y].to_i && xhead == food_part[:x].to_i && yhead != 0 && possible_moves.length > 1
        possible_moves.delete("down")
      elsif yhead + 1 == food_part[:y].to_i && xhead == food_part[:x].to_i && yhead != bheight - 1 && possible_moves.length > 1
        possible_moves.delete("up")
      end
    end
  end

 move = possible_moves.sample
 {"move": move}

end
