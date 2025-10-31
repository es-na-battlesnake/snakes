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

#Get snake health 
@health = board[:you][:health]


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

# Ranking scale idea
# If snake head or wall is near, just immediately delete the move
# From a scale of 0-10
# If enemy snake head is in the corners of the head, those directions = - 9
# If enemy snake body is in the corners of the head, those directions = - 7
# If own snake tail, -5
# If snake head/body is in the direction, that direction distance from head = ?
# If food in that direction = +10 if its close and then scale down 
# If hazard in that direction, -2 for each. 

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

if @snakeheadx == @width - 1
  puts "removing right"
  @possible_moves.delete("right")
end

if @snakeheadx == 0
  puts "removing left"
  @possible_moves.delete("left")
end 

# Set variables for scoring
@upscore = 0
@downscore = 0
@leftscore = 0
@rightscore = 0

# Check for snake if other snakes are near
puts "There are this many snakes " + @othersnakescount.to_s

@othersnakesbody = @othersnakes.map { |s| s[:body] }.flatten
@othersnakeshead = @othersnakes.map { |s| s[:head] }.flatten
puts "Where is enemy snake head" + @othersnakeshead.inspect
puts "Where are enemy snake body" + @othersnakesbody.inspect
@othersnakesbody.each {
  |otherpiece|
    puts "x: #{otherpiece[:x]}, y: #{otherpiece[:y]}"
    if otherpiece[:x] == @snakeheadx && otherpiece[:y] == @snakeheady - 1
      @possible_moves.delete("down")
      puts "Eek! Snake below. Deleting that move."
    elsif otherpiece[:x] == @snakeheadx - 1 && otherpiece[:y] == @snakeheady
      @possible_moves.delete("left")
      puts "Eek! Snake left. Deleting that move"
    elsif otherpiece[:x] == @snakeheadx + 1 && otherpiece[:y] == @snakeheady
      @possible_moves.delete("right")
      puts "Eek! Snake right. Deleting that move"
    elsif otherpiece[:x] == @snakeheadx && otherpiece[:y] == @snakeheady + 1
      @possible_moves.delete("up")
      puts "Eek! Snake above. Deleting that move."
    elsif otherpiece[:x] == @snakeheadx - 1 && otherpiece[:y] == @snakeheady + 1
     @upscore = @upscore - 7
     @leftscore = @leftscore - 7
      puts "Eek! Snake left and up. -7 to up and left."
    elsif otherpiece[:x] == @snakeheadx + 1 && otherpiece[:y] == @snakeheady + 1
      @upscore = @upscore - 7
      @rightscore = @rightscore - 7
      puts "Eek! Snake right and up. -7 to up and right ."
    elsif otherpiece[:x] == @snakeheadx - 1 && otherpiece[:y] == @snakeheady - 1
      @downscore = @downscore - 7
      @leftscore = @leftscore - 7
      puts "Eek! Snake left and down. -7 left and down."
    elsif otherpiece[:x] == @snakeheadx + 1 && otherpiece[:y] == @snakeheady - 1
      @downscore = @downscore - 7
      @rightscore = @rightscore - 7
      puts "Eek! Snake right and down. -7 to down and right"
    else
      puts "No snake body nearby" 
    end
  }
@othersnakeshead.each {
  |headpiece|
    puts "x: #{headpiece[:x].to_i}, y: #{headpiece[:y].to_i}"
    if headpiece[:x] == @snakeheadx && headpiece[:y] == @snakeheady - 1
      @possible_moves.delete("down")
      puts "Eek! Snake head below. Deleting that move."
    elsif headpiece[:x] == @snakeheadx - 1 && headpiece[:y] == @snakeheady
      @possible_moves.delete("left")
      puts "Eek! Snake head left. Deleting that move"
    elsif headpiece[:x] == @snakeheadx + 1 && headpiece[:y] == @snakeheady
      @possible_moves.delete("right")
      puts "Eek! Snake head right. Deleting that move"
    elsif headpiece[:x] == @snakeheadx && headpiece[:y] == @snakeheady + 1
      @possible_moves.delete("up")
      puts "Eek! Snake head above. Deleting that move."
    elsif headpiece[:x] == @snakeheadx - 1 && headpiece[:y] == @snakeheady + 1
      @upscore = @upscore - 9
      @leftscore = @leftscore - 9
      puts "Eek! Snake head left and above corner. -9 up and left."
    elsif headpiece[:x] == @snakeheadx + 1 && headpiece[:y] == @snakeheady + 1
      @upscore = @upscore - 9
      @rightscore = @rightscore - 9
      puts "Eek! Snake head right and above corner. -9 up and right"
    elsif headpiece[:x] == @snakeheadx - 1 && headpiece[:y] == @snakeheady - 1
      @downscore = @downscore - 9
      @leftscore = @leftscore - 9
      puts "Eek! Snake head left and below corner. -9 down and left."
    elsif headpiece[:x] == @snakeheadx + 1 && headpiece[:y] == @snakeheady - 1
      @downscore = @downscore - 9
      @rightscore = @rightscore - 9
      puts "Eek! Snake head right and below corner. -9 down and right."
    else
      puts "No snake head nearby" 
    end
  }



# Set the tail with the last element of the body
@snaketail = @snakebody.last

## REPLACING THIS WITH THE SCORING
# settings these so when there are multiple moves, if the value is not 0, it will stop that being a viable move
#@donotmoveup = 0
#@donotmovedown = 0
#@donotmoveright = 0
#@donotmoveleft = 0

# Avoid the tail
if @snakeheadx == @snaketail[:x] && @snakeheady > @snaketail[:y] 
  @downscore = @downscore - 5
  puts "Trying to avoid tail, down -5"
end
if @snakeheadx == @snaketail[:x] && @snakeheady < @snaketail[:y]
  @upscore = @upscore - 5
  puts "Trying to avoiding tail, up -5"
end
if @snakeheady == @snaketail[:y] && @snakeheadx > @snaketail[:x]
  @leftscore = @leftscore - 5
  puts "Trying to avoid tail, left -5"
end
if @snakeheady == @snaketail[:y] && @snakeheadx < @snaketail[:x]
  @rightscore = @rightscore - 5
  puts "Trying to avoid tail, right -5"
end

# Check if next to food and add 10 to score
@food.each {
  |foodpiece|
    puts "Food coordinates x: #{foodpiece[:x]}, y: #{foodpiece[:y]}"
    if foodpiece[:x] == @snakeheadx && foodpiece[:y] == @snakeheady - 1
      @downscore = @downscore + 10
      puts "Yo! There's food. down + 10"
    elsif foodpiece[:x] == @snakeheadx - 1 && foodpiece[:y] == @snakeheady
      @leftscore = @leftscore + 10
      puts "Yo! There's food. left + 10"
    elsif foodpiece[:x] == @snakeheadx + 1 && foodpiece[:y] == @snakeheady
      @rightscore = @rightscore + 10 
      puts "Yo! There's food. right + 10"
    elsif foodpiece[:x] == @snakeheadx && foodpiece[:y] == @snakeheady + 1
      @upscore = @upscore + 10
      puts "Yo! There's food. up + 10"
    else
      puts "No food adjacent" 
    end
  }

# How much food in each direction
@food.each {
  |foodpiece|
    puts "Food coordinates x: #{foodpiece[:x]}, y: #{foodpiece[:y]}"
  if foodpiece[:x] == @snakeheadx
    # food is to above
    if foodpiece[:y] > @snakeheady
      @fooddistance = foodpiece[:y] - @snakeheady
      # Adjusting the distance to subtract from the board size.
      @fooddistance = @height - @fooddistance
      @upscore = @upscore + @fooddistance
      puts "Food to above, above + #{@fooddistance}"
    elsif foodpiece[:y] < @snakeheady
      # food is below
      @fooddistance = @snakeheady - foodpiece[:y]
      # Adjusting the distance to subtract from the board size.
      @fooddistance = @height - @fooddistance
      @downscore = @downscore + @fooddistance
      puts "Food to the below, below + #{@fooddistance}"
    end
  elsif foodpiece[:y] == @snakeheady
    # food is to the right
    if foodpiece[:x] > @snakeheadx
      @fooddistance = foodpiece[:x] - @snakeheadx
      # Adjusting the distance to subtract from the board size.
      @fooddistance = @width - @fooddistance
      @rightscore = @rightscore + @fooddistance
      puts "Food is to the right, right + #{@fooddistance}"
    elsif foodpiece[:x] < @snakeheadx
      # food is to the left
      @fooddistance = @snakeheadx - foodpiece[:x]
      # Adjusting the distance to subtract from the board size.
      @fooddistance = @width - @fooddistance
      @leftscore = @leftscore + @fooddistance
      puts "Food to the left, down + #{@fooddistance}"
    end
  end
} 

# Check for hazards
@hazards.each {
  |hazardpiece|
    puts "Hazard coordinates x: #{hazardpiece[:x]}, y: #{hazardpiece[:y]}"
    if hazardpiece[:x] <= @snakeheadx 
      if @health > 16
      @leftscore = @leftscore - 0.5
      puts "Hazard to left, down -.5"
      elsif @health < 16
      @leftscore = @leftscore - 100
      puts "Hazard to left and health is low, -100 to left"
      end
    elsif hazardpiece[:x] >= @snakeheadx
      if @health > 16
      @rightscore = @rightscore - 0.5
      puts "Hazard to the right, right -.5"
      elsif @health < 16
      @rightscore = @rightscore - 100
      puts "Hazard to right and health is low, -100 to right"
      end
    elsif hazardpiece[:y] <= @snakeheady
      if @health > 16
      @downscore = @downscore - 0.5
      puts "Hazard below, down -.5"
      elsif @health < 16
      @downscore = @downscore - 100
      puts "Hazard below and health is low, -100 to down"
      end
    elsif hazardpiece[:y] >= @snakeheady 
      if @health > 16
      @upscore = @upscore - 0.5
      puts "Hazard above, up -.5"
      elsif @health < 16
      @upscore = @upscore - 100
      puts "Hazard above and health is low, -100 to up"
      end
    else
      puts "No hazards adjacent" 
    end
  }

  # Add snake head checking two spaces away

# Prints out the possible moves
puts "Remaining moves after removing collisions, snakes, walls and searching for food"
puts @possible_moves.inspect 
puts "Length of possible_moves: #{@possible_moves.length}"
puts "Is possible_moves empty: #{@possible_moves.empty?}"
puts "up score:" + @upscore.to_s
puts "down score:" + @downscore.to_s
puts "left score:" + @leftscore.to_s
puts "right score:" + @rightscore.to_s

@scores = [@upscore, @downscore, @leftscore, @rightscore] 

# If the there is a tie between min and max move, use wall distance to break the tie
if @scores.max == @scores.min
  puts "Tie between max and min"
  @scores.each {
    |score|
      if score == @upscore
        # find distance from wall
        @wallupdistance = @height - @snakeheady
        @upscore = @upscore + @wallupdistance
        puts "up score + wall up distance: #{@upscore}"
      elsif score == @downscore
        # find distance from wall
        @walldowndistance = @snakeheady - @height
        @downscore = @downscore + @walldowndistance
        puts "down score + wall down distance: #{@downscore}"
      elsif score == @leftscore
        # find distance from wall
        @wallleftdistance = @width - @snakeheadx
        @leftscore = @leftscore + @wallleftdistance
        puts "left score + wall left distance: #{@leftscore}"
      elsif score == @rightscore
        # find distance from wall
        @wallrightdistance = @snakeheadx - @width
        @rightscore = @rightscore + @wallrightdistance
        puts "right score + wall right distance: #{@rightscore}"
      end
    }
end
# reset the scores with new values
@scores.clear
@possible_moves.each {
  |move|
    if move == "up"
      @scores.push(@upscore)
    elsif move == "down"
      @scores.push(@downscore)
    elsif move == "left"
      @scores.push(@leftscore)
    elsif move == "right"
      @scores.push(@rightscore)
    end
  }



puts "best score is:" + @scores.max.to_s
# Use scoring if there is more than 1 move
if @possible_moves.length > 1
  @possible_moves.each {
    |move|
      if move == "up" && @upscore == @scores.max
        @possible_moves.clear
        @possible_moves.push("up")
      elsif move == "down" && @downscore == @scores.max
        @possible_moves.clear
        @possible_moves.push("down")
      elsif move == "left" && @leftscore == @scores.max
        @possible_moves.clear
        @possible_moves.push("left")
      elsif move == "right" && @rightscore == @scores.max
        @possible_moves.clear
        @possible_moves.push("right")
      end
  }
end

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
