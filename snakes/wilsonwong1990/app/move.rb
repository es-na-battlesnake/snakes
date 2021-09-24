# This function is called on every turn of a game. It's how your Battlesnake decides where to move.
# Valid moves are "up", "down", "left", or "right".
# TODO: Use the information in board to decide your next move.
def move(board)
  puts board

# Height and width of the board
@height = board[:board][:height]
@width = board[:board][:width]

# all possible moves
@possible_moves = ["up", "down", "left", "right"] 

#get snakes length
@snakelength = board[:you][:length]

# get where food is
@food = board[:board][:food]
   
# get where hazards are
@hazards = board[:board][:hazards]
   
# get your snakehead
@snakeheadx = board[:you][:head][:x]
@snakeheady = board[:you][:head][:y] 

 # get the snakes body
@snakebody = board[:you][:body]

# Got the idea from https://stackoverflow.com/questions/15784503/ruby-method-to-print-and-neat-an-array
p @snakebody
puts @snakebody.inspect
# Check the snake body and avoid a collision. Checks each body part and see if its in an adjacent square to the head
@snakebody.each {
  |piece|
    puts "x: #{piece[:x]}, y: #{piece[:y]}"
    if piece[:x] == @snakeheadx && piece[:y] + 1 == @snakeheady
      @possible_moves.delete("down")
      puts "Body is below head, removing down"
    elsif piece[:x] + 1 == @snakeheadx && piece[:y] == @snakeheady
      @possible_moves.delete("left")
      puts "Body is to left of head, removing left"
    elsif piece[:x] -1 == @snakeheadx && piece[:y] == @snakeheady
      @possible_moves.delete("right")
      puts "Body is to the right of head, removing right"
    elsif piece[:x] == @snakeheadx && piece[:y] - 1 == @snakeheady
      @possible_moves.delete("up")
      puts "Body is above head, removing up"
    else
      puts "No body collisions" 
    end
  }

# Avoid the board edges

if @snakeheady == @height - 1
  puts "removing up"
  @possible_moves.delete("up")
end

if @snakeheady == 0
  puts "removing down"
  @possible_moves.delete("down")
end

if@snakeheadx == @width - 1
  puts "removing right"
  @possible_moves.delete("right")
end

if@snakeheadx == 0
  puts "removing left"
  @possible_moves.delete("left")
end 

# Set the tail with the last element of the body
@snaketail = @snakebody.last

# settings these so when there are multiple moves, if the value is no 0, it will stop that being a viable move
donotmoveup = 0
donotmovedown = 0
donotmoveright = 0
donotmoveleft =0

# Avoid the tail
if @snakeheadx == @snaketail[:x] && @snakeheady > @snaketail[:y] 
  @possible_moves.delete("down")
  donotmovedown = 1
  puts "Avoiding tail, removing down"
end
if @snakeheadx == @snaketail[:x] && @snakeheady < @snaketail[:y]
  @possible_moves.delete("up")
  donotmoveup = 1
  puts "Avoiding tail, removing up"
end
if @snakeheady == @snaketail[:y] && @snakeheadx > @snaketail[:x]
  @possible_moves.delete("left")
  donotmoveleft = 1
  puts "Avoiding tail, removing left"
end
if @snakeheady == @snaketail[:y] && @snakeheadx < @snaketail[:x]
  @possible_moves.delete("right")
  donotmoveright = 1
  puts "Avoiding tail, removing right"
end
if @snakeheadx > @snaketail[:x] && @snakeheady > @snaketail[:y]
  @possible_moves.delete("down")
  @possible_moves.delete("left")
  donotmovedown = 1
  donotmoveleft = 1
  puts "Avoiding tail, removing down and left"
end
if @snakeheadx > @snaketail[:x] && @snakeheady < @snaketail[:y]
  @possible_moves.delete("up")
  @possible_moves.delete("right")
  donotmoveup = 1
  donotmoveright = 1
  puts "Avoiding tail, removing up and right"
end


# Prints out the possible moves
puts "Remaining moves after removing head collisions and walls"
p @possible_moves
puts @possible_moves.inspect

# if multiple moves are possible, try get distances from the walls
@moves_available = Array.new
@possible_moves.each {
  |moves|
  if moves == "up"
    upvalue = @height - @snakeheady
    @moves_available.push(upvalue)
  elsif moves == "down"
    downvalue = @snakeheady
    @moves_available.push(downvalue)
  elsif moves == "left"
    leftvalue = @snakeheadx
    @moves_available.push(leftvalue)
  elsif moves == "right"
    rightvalue = @width - @snakeheadx
    @moves_available.push(rightvalue)
  end
}

upvalue = @height - @snakeheady
downvalue = @snakeheady
leftvalue = @snakeheadx
rightvalue = @width - @snakeheadx

# check if the values are available then what is the largest value
# Not quite ready. Maybe look for food instead.
#if @possible_moves.length > 1 && @moves_available.max == upvalue && donotmoveup == 0
#  @possible_moves.clear
#  @possible_moves.push("up")
#  puts "multiple moves, best move is up"
#elsif @possible_moves.length > 1 && @moves_available.max == upvalue && donotmoveup > 0
#  @moves_available.delete(@moves_available.max)
#end
#if @possible_moves.length > 1 && @moves_available.max == downvalue && donotmovedown == 0
#  @possible_moves.clear
#  @possible_moves.push("down")
#  puts "multiple moves, best move is down"
#elsif @possible_moves.length > 1 && @moves_available.max == downvalue && donotmovedown > 0
#@moves_available.delete(@moves_available.max)
#end 
#if @possible_moves.length > 1 && @moves_available.max == leftvalue && donotmoveleft == 0
#  @possible_moves.clear
#  @possible_moves.push("left")
#  puts "multiple moves, best move is left"
#elsif @possible_moves.length > 1 && @moves_available.max == leftvalue && donotmoveleft > 0
#@moves_available.delete(@moves_available.max)
#end
#if @possible_moves.length > 1 && @moves_available.max == rightvalue && donotmoveright == 0
#  @possible_moves.clear
#  @possible_moves.push("right")
#  puts "multiple moves, best move is right"
#elsif @possible_moves.length > 1 && @moves_available.max == rightvalue && donotmoveright > 0
#@moves_available.delete(@moves_available.max)
#end 

move = @possible_moves.sample  
puts "MOVE: " + move
{"move": move}
end
