# Example response
# {:board=>{:height=>11, :width=>11, :snakes=>[{:id=>"gs_rm6jTJrPtfFxrWFVXTTCxd7P", :name=>"codespaces-dev-snek", :latency=>"26", :health=>82, :body=>[{:x=>7, :y=>5}, {:x=>7, :y=>6}, {:x=>6, :y=>6}], :head=>{:x=>7, :y=>5}, :length=>3, :shout=>"", :squad=>""}, {:id=>"gs_K9Y3tCTjy4JRpqqBCtKPrGqX", :name=>"Super Awesome Chaos Snek", :latency=>"26", :health=>96, :body=>[{:x=>5, :y=>3}, {:x=>6, :y=>3}, {:x=>6, :y=>4}, {:x=>6, :y=>5}, {:x=>5, :y=>5}], :head=>{:x=>5, :y=>3}, :length=>5, :shout=>"", :squad=>""}], :food=>[{:x=>2, :y=>4}, {:x=>1, :y=>3}, {:x=>1, :y=>6}, {:x=>10, :y=>6}, {:x=>3, :y=>1}, {:x=>10, :y=>4}], :hazards=>[]}, :you=>{:id=>"gs_rm6jTJrPtfFxrWFVXTTCxd7P", :name=>"codespaces-dev-snek", :latency=>"26", :health=>82, :body=>[{:x=>7, :y=>5}, {:x=>7, :y=>6}, {:x=>6, :y=>6}], :head=>{:x=>7, :y=>5}, :length=>3, :shout=>"", :squad=>""}}

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

# Get other snakes 
@othersnakes = board[:board][:snakes]

#Get number of other snakes
@othersnakescount = board[:board][:snakes].length


# Think of the moves as a 3x3 grid. The head is in the middle at (2,2). 
# ---------------
# |  |    |     |
# ---------------
# |  |head|     |
# ---------------
# |  | tail|     |
# ---------------
# It only has really 3 moves: (2,1), (2,3), (1,2).
# So we need to check each of those cells to see if something occupies it.

# Generate a list of spaces to check
@spaceabovex = @snakeheadx 
@spaceabovey = @snakeheady + 1
@spaceleftx = @snakeheadx - 1
@spacelefty = @snakeheady
@spacerightx = @snakeheadx + 1
@spacerighty = @snakeheady
@spacebelowx = @snakeheadx
@spacebelowy = @snakeheady - 1

# ------
# Got the idea from https://stackoverflow.com/questions/15784503/ruby-method-to-print-and-neat-an-array
p @snakebody
puts @snakebody.inspect
# Check the snake body and avoid a collision. Checks each body part and see if its in an adjacent square to the head
@snakebody.each {
  |piece|
    puts "x: #{piece[:x]}, y: #{piece[:y]}"
    if piece[:x] == @spacebelowx && piece[:y] == @spacebelowy
      @possible_moves.delete("down")
      puts "Body is below head, removing down"
    elsif piece[:x] == @spaceleftx && piece[:y] == @spacelefty
      @possible_moves.delete("left")
      puts "Body is to left of head, removing left"
    elsif piece[:x] == @spacerightx && piece[:y] == @spacerighty
      @possible_moves.delete("right")
      puts "Body is to the right of head, removing right"
    elsif piece[:x] == @spaceabovex && piece[:y] == @spaceabovey
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

# Check for snake if other snakes are near
puts "There are this many snakes " + @othersnakescount.to_s

@othersnakesbody = @othersnakes.map { |s| s[:body] }.flatten
@othersnakeshead = @othersnakes.map { |s| s[:head] }.flatten
puts "Where is enemy snake head" + @othersnakeshead.inspect
puts "Where are enemy snake body" + @othersnakesbody.inspect
@othersnakesbody.each {
  |otherpiece|
    puts "x: #{otherpiece[:x]}, y: #{otherpiece[:y]}"
    if otherpiece[:x] == @spacebelowx && otherpiece[:y] == @spacebelowy
      @possible_moves.delete("down")
      puts "Eek! Snake below. Deleting that move."
    elsif otherpiece[:x] == @spaceleftx && otherpiece[:y] == @spacelefty
      @possible_moves.delete("left")
      puts "Eek! Snake left. Deleting that move"
    elsif otherpiece[:x] == @spacerightx && otherpiece[:y] == @spacerighty
      @possible_moves.delete("right")
      puts "Eek! Snake right. Deleting that move"
    elsif otherpiece[:x] == @spaceabovex && otherpiece[:y] == @spaceabovey
      @possible_moves.delete("up")
      puts "Eek! Snake above. Deleting that move."
    elsif otherpiece[:x] == @snakeheadx - 1 && otherpiece[:y] == @snakeheady + 1
      @possible_moves.delete("up")
      @possible_moves.delete("left")
      puts "Eek! Snake left and up. Deleting that move."
    elsif otherpiece[:x] == @snakeheadx + 1 && otherpiece[:y] == @snakeheady + 1
      @possible_moves.delete("up")
      @possible_moves.delete("right")
      puts "Eek! Snake right and up. Deleting that move."
    elsif otherpiece[:x] == @snakeheadx - 1 && otherpiece[:y] == @snakeheady - 1
      @possible_moves.delete("down")
      @possible_moves.delete("left")
      puts "Eek! Snake left and down. Deleting that move."
    elsif otherpiece[:x] == @snakeheadx + 1 && otherpiece[:y] == @snakeheady - 1
      @possible_moves.delete("down")
      @possible_moves.delete("right")
      puts "Eek! Snake right and down. Deleting that move."
    else
      puts "No snake body nearby" 
    end
  }
@othersnakeshead.each {
  |headpiece|
    puts "x: #{headpiece[:x].to_i}, y: #{headpiece[:y].to_i}"
    if headpiece[:x] == @spacebelowx && headpiece[:y] == @spacebelowy
      @possible_moves.delete("down")
      puts "Eek! Snake head below. Deleting that move."
    elsif headpiece[:x] == @spaceleftx && headpiece[:y] == @spacelefty
      @possible_moves.delete("left")
      puts "Eek! Snake head left. Deleting that move"
    elsif headpiece[:x] == @spacerightx && headpiece[:y] == @spacerighty
      @possible_moves.delete("right")
      puts "Eek! Snake head right. Deleting that move"
    elsif headpiece[:x] == @spaceabovex && headpiece[:y] == @spaceabovey
      @possible_moves.delete("up")
      puts "Eek! Snake head above. Deleting that move."
    elsif headpiece[:x] == @snakeheadx - 1 && headpiece[:y] == @snakeheady + 1
      @possible_moves.delete("up")
      @possible_moves.delete("left")
      puts "Eek! Snake head left and above corner. Deleting that move."
    elsif headpiece[:x] == @snakeheadx + 1 && headpiece[:y] == @snakeheady + 1
      @possible_moves.delete("up")
      @possible_moves.delete("right")
      puts "Eek! Snake head right and above corner. Deleting that move."
    elsif headpiece[:x] == @snakeheadx - 1 && headpiece[:y] == @snakeheady - 1
      @possible_moves.delete("down")
      @possible_moves.delete("left")
      puts "Eek! Snake head left and below corner. Deleting that move."
    elsif headpiece[:x] == @snakeheadx + 1 && headpiece[:y] == @snakeheady - 1
      @possible_moves.delete("down")
      @possible_moves.delete("right")
      puts "Eek! Snake head right and below corner. Deleting that move."
    else
      puts "No snake head nearby" 
    end
  }



# Set the tail with the last element of the body
@snaketail = @snakebody.last

# settings these so when there are multiple moves, if the value is not 0, it will stop that being a viable move
@donotmoveup = 0
@donotmovedown = 0
@donotmoveright = 0
@donotmoveleft = 0

# Avoid the tail
if @snakeheadx == @snaketail[:x] && @snakeheady > @snaketail[:y] 
  @possible_moves.delete("down")
  @donotmovedown = @donotmovedown + 1
  puts "Avoiding tail, removing down"
end
if @snakeheadx == @snaketail[:x] && @snakeheady < @snaketail[:y]
  @possible_moves.delete("up")
  @donotmoveup = @donotmoveup + 1
  puts "Avoiding tail, removing up"
end
if @snakeheady == @snaketail[:y] && @snakeheadx > @snaketail[:x]
  @possible_moves.delete("left")
  @donotmoveleft = @donotmoveleft + 1
  puts "Avoiding tail, removing left"
end
if @snakeheady == @snaketail[:y] && @snakeheadx < @snaketail[:x]
  @possible_moves.delete("right")
  @donotmoveright = @donotmoveright + 1
  puts "Avoiding tail, removing right"
end

# Check if next to food and so, move to it, overriding other moves
@food.each {
  |foodpiece|
    puts "Food coordinates x: #{foodpiece[:x]}, y: #{foodpiece[:y]}"
    if foodpiece[:x] == @spacebelowx && foodpiece[:y] == @spacebelowy
      @possible_moves.clear
      @possible_moves.push("down")
      puts "Yo! There's food. Going down"
    elsif foodpiece[:x] == @spaceleftx && foodpiece[:y] == @spacelefty
      @possible_moves.clear
      @possible_moves.push("left")
      puts "Yo! There's food. Going left"
    elsif foodpiece[:x] == @spacerightx && foodpiece[:y] == @spacerighty
      @possible_moves.clear
      @possible_moves.push("right")
      puts "Yo! There's food. Going right"
    elsif foodpiece[:x] == @spaceabovex && foodpiece[:y] == @spaceabovey
      @possible_moves.clear
      @possible_moves.push("up")
      puts "Yo! There's food Going up"
    else
      puts "No food" 
    end
  }


# Prints out the possible moves
puts "Remaining moves after removing collisions, snakes, walls and searching for food"
puts @possible_moves.inspect 
puts "Length of possible_moves: #{@possible_moves.length}"
puts "Is possible_moves empty: #{@possible_moves.empty?}"

# Safety net. If there are no moves, then just move randomly
if @possible_moves.empty? == true
  puts "No moves in array. Repopulating with all moves"
  @possible_moves.push("up")
  @possible_moves.push("down")
  @possible_moves.push("left")
  @possible_moves.push("right")
end

move = @possible_moves.sample  
puts "MOVE: " + move.to_s
{"move": move}
end
