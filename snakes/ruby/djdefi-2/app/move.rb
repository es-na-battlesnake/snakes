# frozen_string_literal: true

$VERBOSE = nil
# Health find threshold variable


# This function is called on every turn of a game. It's how your Battlesnake decides where to move.
# Valid moves are "up", "down", "left", or "right".
# TODO: Use the information in board to decide your next move.
def move(board)
  # Define the current head position and board size
  head = board["you"]["head"]
  height = board["height"]
  width = board["width"]

  # Get a list of all possible moves
  possible_moves = ["up", "down", "left", "right"]

  # Remove moves that would result in a collision with a wall
  possible_moves.reject! { |move| is_wall_collision?(head, move, height, width) }

  # Remove moves that would result in a collision with another snake
  possible_moves.reject! { |move| is_snake_collision?(head, move, board["snakes"]) }

  # Choose the longest and most survivable path among the remaining possible moves
  move = find_best_move(head, possible_moves, board["snakes"], height, width)

  puts "MOVE: " + move
  { "move": move }
end

# Helper function to check if a move would result in a collision with a wall
def is_wall_collision?(head, move, height, width)
  next_pos = get_next_position(head, move)
  next_pos["x"] < 0 || next_pos["x"] >= width || next_pos["y"] < 0 || next_pos["y"] >= height
end

# Helper function to check if a move would result in a collision with another snake
def is_snake_collision?(head, move, snakes)
  next_pos = get_next_position(head, move)
  snakes.any? { |snake| snake["body"].include?(next_pos) }
end

# Helper function to get the position of the next move
def get_next_position(head, move)
  case move
  when "up"
    { "x": head["x"], "y": head["y"] + 1 }
  when "down"
    { "x": head["x"], "y": head["y"] - 1 }
  when "left"
    { "x": head["x"] - 1, "y": head["y"] }
  when "right"
    { "x": head["x"] + 1, "y": head["y"] }
  end
end

# Helper function to find the longest and most survivable path among the possible moves
def find_best_move(head, possible_moves, snakes, height, width)
  max_path_length = -1
  best_move = possible_moves.sample

  possible_moves.each do |move|
    path_length = find_path_length(head, move, snakes, height, width)

    if path_length > max_path_length
      max_path_length = path_length
      best_move = move
    end
  end

  best_move
end

# Helper function to find the length of the longest path for a given move
def find_path_length(x, y, move, board, visited)
  height = board["height"]
  width = board["width"]
  next_x, next_y = get_next_position(x, y, move)

  # Check if the next position is a valid move
  if next_x < 0 || next_x >= width || next_y < 0 || next_y >= height
    return 0
  end

  # Check if the next position is already visited or blocked by a snake
  if visited.include?([next_x, next_y]) || is_obstacle?(next_x, next_y, board)
    return 0
  end

  visited.push([next_x, next_y])

  # Check the longest path for each possible move
  lengths = []
  ["up", "down", "left", "right"].each do |direction|
    if direction != opposite_direction(move)
      lengths.push(find_path_length(next_x, next_y, direction, board, visited))
    end
  end

  # Return the length of the longest path
  return 1 + (lengths.max || 0)
end

# Helper function to find the length of the longest path for a given move
def longest_path_length(board, move, start, visited)
  # Calculate the new head position after making the move
  head = start.clone
  case move
  when "up"
    head["y"] += 1
  when "down"
    head["y"] -= 1
  when "left"
    head["x"] -= 1
  when "right"
    head["x"] += 1
  end

  # Check if the new head position is valid and not already visited
  if is_valid_position(board, head) && !visited.include?(head)
    # Mark the new head position as visited
    visited.add(head)

    # Find the longest path length for each possible next move
    possible_moves = ["up", "down", "left", "right"]
    path_lengths = possible_moves.map { |next_move|
      longest_path_length(board, next_move, head, visited)
    }

    # Return the longest path length
    return path_lengths.max + 1
  else
    # The new head position is not valid or already visited, so the longest path length is 0
    return 0
  end
end

# Helper function to check if a position is valid on the board
def is_valid_position(board, position)
  return position["x"] >= 0 && position["x"] < board["width"] && position["y"] >= 0 && position["y"] < board["height"]
end

# This function is called on every turn of a game. It's how your Battlesnake decides where to move.
# Valid moves are "up", "down", "left", or "right".
# TODO: Use the information in board to decide your next move.
def move(board)
  puts board

  # Choose the move that leads to the longest path length
  possible_moves = ["up", "down", "left", "right"]
  longest_path_lengths = possible_moves.map { |move|
    longest_path_length(board, move, board["you"]["head"], Set.new([board["you"]["head"]]))
  }
  longest_path_length = longest_path_lengths.max
  longest_moves = longest_path_lengths.each_with_index.select { |length, index| length == longest_path_length }.map { |length, index| possible_moves[index] }
  move = longest_moves.sample
  puts "MOVE: " + move
  { "move": move }
end
