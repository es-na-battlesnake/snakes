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
    elsif piece[:x] - 1 == @snakeheadx && piece[:y] == @snakeheady
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

# settings these so when there are multiple moves, if the value is not 0, it will stop that being a viable move
@donotmoveup = 0
@donotmovedown = 0
@donotmoveright = 0
@donotmoveleft =0

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
if @snakeheadx > @snaketail[:x] && @snakeheady > @snaketail[:y]
  @possible_moves.delete("down")
  @possible_moves.delete("left")
  @donotmovedown = @donotmovedown + 1
  @donotmoveleft = @donotmoveleft + 1
  puts "Avoiding tail, removing down and left"
end
if @snakeheadx > @snaketail[:x] && @snakeheady < @snaketail[:y]
  @possible_moves.delete("up")
  @possible_moves.delete("right")
  @donotmoveup = @donotmoveup + 1
  @donotmoveright = @donotmoveright + 1
  puts "Avoiding tail, removing up and right"
end


# Prints out the possible moves
puts "Remaining moves after removing head collisions and walls"
puts @possible_moves.inspect 
puts "Length of possible_moves: #{@possible_moves.length}"
puts "Is possible_moves empty: #{@possible_moves.empty?}"

if @possible_moves.empty? == true
  puts "No moves in array. Repopulating with all moves"
  @possible_moves.push("up")
  @possible_moves.push("down")
  @possible_moves.push("left")
  @possible_moves.push("right")
end

#upvalue = @height - @snakeheady
#downvalue = @snakeheady
#leftvalue = @snakeheadx
#rightvalue = @width - @snakeheadx

# if multiple moves are possible, try get distances from the walls
@moves_available = Array.new
@possible_moves.each {
  |moves|
  if moves == "up"
    @upvalue = @height - @snakeheady
    @moves_available.push(@upvalue)
    puts "upvalue: #{@upvalue}"
  elsif moves == "down"
    @downvalue = @snakeheady
    @moves_available.push(@downvalue)
    puts "downvalue: #{@downvalue}"
  elsif moves == "left"
    @leftvalue = @snakeheadx
    @moves_available.push(@leftvalue)
    puts "leftvalue: #{@leftvalue}"
  elsif moves == "right"
    @rightvalue = @width - @snakeheadx
    @moves_available.push(@rightvalue)
    puts "rightvalue: #{@rightvalue}"
  end
}

#Print out moves available
#p @moves_available

puts "Moves that are available:" + @moves_available.inspect

@moves_length = @possible_moves.length

puts "Moves left were:" + @moves_length.to_i.to_s
puts "Max move was:" + @moves_available.max.to_i.to_s

# check if the values are available then what is the largest value
if @moves_length > 1 && @moves_available.max == @upvalue && @donotmoveup == 0
  @possible_moves.clear
  @possible_moves.push("up")
  puts "multiple moves, best move is up"
end
if @moves_length > 1 && @moves_available.max == @downvalue && @donotmovedown == 0
  @possible_moves.clear
  @possible_moves.push("down")
  puts "multiple moves, best move is down"
end
if @moves_length > 1 && @moves_available.max == @leftvalue && @donotmoveleft == 0
  @possible_moves.clear
  @possible_moves.push("left")
  puts "multiple moves, best move is left"
end
if @moves_length > 1 && @moves_available.max == @rightvalue && @donotmoveright == 0
  @possible_moves.clear
  @possible_moves.push("right")
  puts "multiple moves, best move is right"
end 

# check if these if statements work

puts "Moves available were:" + @moves_available.inspect



move = @possible_moves.sample  
puts "MOVE: " + move.to_s
{"move": move}
end
