# frozen_string_literal: true

# Elite Battlesnake Strategies for 90%+ Win Rate
# 
# This module contains advanced AI techniques and strategies designed to push
# the Ruby snake's performance from competitive (60-70%) to elite (90%+).
#
# Key principles for elite performance:
# 1. Perfect safety - never make avoidable mistakes
# 2. Advanced opponent modeling and prediction
# 3. Dynamic strategy adaptation based on game state
# 4. Sophisticated space control and territory management
# 5. Elite food seeking with risk/reward optimization
# 6. Endgame mastery for long-term victories

require 'set'

module EliteStrategies
  
  # Elite opponent modeling - predict enemy moves with high accuracy
  def predict_enemy_moves_elite(board_state, turn_number)
    enemy_predictions = {}
    
    board_state[:snakes_heads_not_my_head].each do |enemy_head|
      enemy_snake = board_state[:snakes].find { |s| s[:head] == enemy_head }
      next unless enemy_snake
      
      # Advanced prediction based on multiple factors
      safe_moves = get_safe_moves_for_position(enemy_head, board_state)
      next if safe_moves.empty?
      
      # Analyze enemy behavior patterns
      predicted_move = predict_enemy_behavior(enemy_snake, safe_moves, board_state, turn_number)
      enemy_predictions[enemy_snake[:id]] = predicted_move if predicted_move
    end
    
    enemy_predictions
  end
  
  # Sophisticated enemy behavior prediction
  def predict_enemy_behavior(enemy_snake, safe_moves, board_state, turn_number)
    # Weight factors for different move types
    move_scores = {}
    
    safe_moves.each do |move_pos|
      score = 0
      
      # 1. Survival priority - prefer moves with more space
      space_after_move = calculate_space_from_position(move_pos, board_state, enemy_snake[:length] * 2)
      score += space_after_move * 2
      
      # 2. Food seeking behavior (if health is low)
      if enemy_snake[:health] < 85 && !board_state[:food].empty?
        nearest_food = board_state[:food].min_by { |f| manhattan_distance(move_pos, f) }
        distance_to_food = manhattan_distance(move_pos, nearest_food)
        score += (20 - distance_to_food) * 3 # Closer to food = higher score
      end
      
      # 3. Center preference (typical snake behavior)
      center_x = board_state[:width] / 2
      center_y = board_state[:height] / 2
      distance_to_center = manhattan_distance(move_pos, {x: center_x, y: center_y})
      score += (10 - distance_to_center) * 1
      
      # 4. Avoid our snake (opponents try to avoid us)
      distance_to_us = manhattan_distance(move_pos, board_state[:head])
      score += distance_to_us * 1.5 if distance_to_us > 0
      
      # 5. Early game - prefer edges less
      if turn_number < 20
        if move_pos[:x] == 0 || move_pos[:x] == board_state[:width] - 1 || 
           move_pos[:y] == 0 || move_pos[:y] == board_state[:height] - 1
          score -= 5
        end
      end
      
      move_scores[move_pos] = score
    end
    
    # Return the highest scoring move
    move_scores.max_by { |_pos, score| score }&.first
  end
  
  # Elite food evaluation - only go for food that's strategically advantageous
  def evaluate_food_elite(food_pos, board_state, turn_number)
    return 0 if food_pos.nil?
    
    score = 0
    
    # Base distance penalty
    distance = manhattan_distance(board_state[:head], food_pos)
    score -= distance * 2
    
    # Safety evaluation - is the food in a dangerous area?
    food_neighbors = adjacent_cells(food_pos[:x], food_pos[:y])
    
    # Check for enemy proximity
    board_state[:snakes_heads_not_my_head].each do |enemy_head|
      enemy_snake = board_state[:snakes].find { |s| s[:head] == enemy_head }
      next unless enemy_snake
      
      enemy_distance = manhattan_distance(food_pos, enemy_head)
      if enemy_distance <= 2
        # Food is near an enemy - evaluate risk/reward
        if enemy_snake[:length] >= board_state[:length]
          score -= 20 # Dangerous if enemy is equal/larger
        else
          score += 5  # Opportunity if enemy is smaller
        end
      end
    end
    
    # Check if food is in a "trap" - surrounded area with limited exits
    open_neighbors = food_neighbors.count do |neighbor|
      !is_wall_for_board?(neighbor[:x], neighbor[:y], board_state) &&
      !is_occupied_for_board?(neighbor[:x], neighbor[:y], board_state) &&
      !is_dangerous_for_board?(neighbor[:x], neighbor[:y], board_state)
    end
    
    if open_neighbors < 2
      score -= 25 # Very dangerous - could be a trap
    elsif open_neighbors == 2
      score -= 10 # Somewhat risky
    end
    
    # Bonus for food that would give us strategic advantage
    if turn_number > 10 # Not in early game
      # Check if getting this food would put us in a dominant position
      our_length_after = board_state[:length] + 1
      longest_enemy = board_state[:snakes].reject { |s| s[:id] == board_state[:our_id] }.max_by { |s| s[:length] }&.dig(:length) || 0
      
      if our_length_after > longest_enemy + 2
        score += 15 # Great strategic advantage
      elsif our_length_after > longest_enemy
        score += 8 # Good advantage
      end
    end
    
    # Health urgency factor
    health_factor = (100 - board_state[:health]) / 10.0
    score += health_factor * 3
    
    score
  end
  
  # Elite space control - calculate optimal territory management
  def calculate_territory_control_elite(board_state, depth_limit = nil)
    our_controlled_space = 0
    enemy_controlled_spaces = {}
    
    # Calculate space we can reach first
    our_reachable = calculate_reachable_cells(board_state[:head], board_state, depth_limit)
    our_controlled_space = our_reachable.size
    
    # Calculate enemy reachable spaces
    board_state[:snakes_heads_not_my_head].each do |enemy_head|
      enemy_snake = board_state[:snakes].find { |s| s[:head] == enemy_head }
      next unless enemy_snake
      
      enemy_reachable = calculate_reachable_cells(enemy_head, board_state, depth_limit)
      enemy_controlled_spaces[enemy_snake[:id]] = enemy_reachable.size
    end
    
    # Calculate contested areas
    contested_cells = 0
    our_reachable.each do |our_cell|
      enemy_controlled_spaces.each do |_enemy_id, enemy_cells|
        if enemy_cells.include?(our_cell)
          contested_cells += 1
          break
        end
      end
    end
    
    {
      our_controlled: our_controlled_space,
      enemy_controlled: enemy_controlled_spaces,
      contested: contested_cells,
      advantage_ratio: our_controlled_space.to_f / (enemy_controlled_spaces.values.max || 1)
    }
  end
  
  # Calculate cells reachable from a position within a depth limit
  def calculate_reachable_cells(start_pos, board_state, max_depth = nil)
    return Set.new if max_depth == 0
    
    reachable = Set.new
    queue = [[start_pos, 0]]
    visited = Set.new([start_pos])
    
    while !queue.empty?
      current_pos, depth = queue.shift
      reachable.add(current_pos)
      
      next if max_depth && depth >= max_depth
      
      adjacent_cells(current_pos[:x], current_pos[:y]).each do |neighbor|
        next if visited.include?(neighbor)
        next if is_wall_for_board?(neighbor[:x], neighbor[:y], board_state)
        next if is_occupied_for_board?(neighbor[:x], neighbor[:y], board_state)
        
        visited.add(neighbor)
        queue << [neighbor, depth + 1]
      end
    end
    
    reachable
  end
  
  # Elite endgame strategy - when we're winning, play perfectly defensive
  def elite_endgame_strategy(board_state, turn_number)
    return nil if turn_number < 50 # Only for late game
    
    # Calculate if we're winning
    our_length = board_state[:length]
    longest_enemy = board_state[:snakes].reject { |s| s[:id] == board_state[:our_id] }.max_by { |s| s[:length] }&.dig(:length) || 0
    
    return nil unless our_length > longest_enemy + 2 # We need significant lead
    
    # In endgame with lead, prioritize:
    # 1. Maximum safety
    # 2. Space control
    # 3. Avoid unnecessary risks
    
    safe_moves = get_ultra_safe_moves(board_state)
    return nil if safe_moves.empty?
    
    # Choose move that maximizes our space while minimizing risk
    best_move = nil
    best_score = -Float::INFINITY
    
    safe_moves.each do |move_dir|
      next_pos = get_position_after_move(board_state[:head], move_dir)
      
      score = 0
      
      # Massive bonus for space control
      space_after_move = calculate_space_from_position(next_pos, board_state, our_length + 10)
      score += space_after_move * 10
      
      # Penalty for being too close to enemies
      board_state[:snakes_heads_not_my_head].each do |enemy_head|
        distance = manhattan_distance(next_pos, enemy_head)
        score += distance * 5 # Further from enemies = better
      end
      
      # Slight preference for center areas (usually safer)
      center_x = board_state[:width] / 2
      center_y = board_state[:height] / 2
      distance_to_center = manhattan_distance(next_pos, {x: center_x, y: center_y})
      score -= distance_to_center * 0.5
      
      if score > best_score
        best_score = score
        best_move = move_dir
      end
    end
    
    best_move
  end
  
  # Get ultra-safe moves (for endgame when we're winning)
  def get_ultra_safe_moves(board_state)
    safe_moves = []
    
    ['up', 'down', 'left', 'right'].each do |direction|
      next_pos = get_position_after_move(board_state[:head], direction)
      
      # Must not be a wall (unless wrapped mode)
      next if is_wall_for_board?(next_pos[:x], next_pos[:y], board_state)
      
      # Must not be occupied
      next if is_occupied_for_board?(next_pos[:x], next_pos[:y], board_state)
      
      # Must not be immediately dangerous
      next if is_dangerous_for_board?(next_pos[:x], next_pos[:y], board_state)
      
      # Must have adequate space after the move (no dead ends)
      space_after = calculate_space_from_position(next_pos, board_state, board_state[:length] * 2)
      next if space_after < board_state[:length] + 5
      
      # Must not put us adjacent to longer enemy snakes
      too_risky = false
      board_state[:snakes_heads_not_my_head].each do |enemy_head|
        enemy_snake = board_state[:snakes].find { |s| s[:head] == enemy_head }
        next unless enemy_snake
        
        if enemy_snake[:length] >= board_state[:length] && manhattan_distance(next_pos, enemy_head) <= 2
          too_risky = true
          break
        end
      end
      next if too_risky
      
      safe_moves << direction
    end
    
    safe_moves
  end
  
  # Calculate space available from a given position
  def calculate_space_from_position(start_pos, board_state, max_depth = 50)
    return 0 if is_wall_for_board?(start_pos[:x], start_pos[:y], board_state)
    return 0 if is_occupied_for_board?(start_pos[:x], start_pos[:y], board_state)
    
    visited = Set.new
    queue = [start_pos]
    visited.add(start_pos)
    
    while !queue.empty? && visited.size < max_depth
      current = queue.shift
      
      adjacent_cells(current[:x], current[:y]).each do |neighbor|
        next if visited.include?(neighbor)
        next if is_wall_for_board?(neighbor[:x], neighbor[:y], board_state)
        next if is_occupied_for_board?(neighbor[:x], neighbor[:y], board_state)
        
        visited.add(neighbor)
        queue << neighbor
      end
    end
    
    visited.size
  end
  
  # Get position after a move
  def get_position_after_move(current_pos, direction)
    case direction
    when 'up'
      { x: current_pos[:x], y: current_pos[:y] + 1 }
    when 'down'
      { x: current_pos[:x], y: current_pos[:y] - 1 }
    when 'left'
      { x: current_pos[:x] - 1, y: current_pos[:y] }
    when 'right'
      { x: current_pos[:x] + 1, y: current_pos[:y] }
    else
      current_pos
    end
  end
  
  # Get safe moves for any position (used for enemy prediction)
  def get_safe_moves_for_position(pos, board_state)
    safe_moves = []
    
    adjacent_cells(pos[:x], pos[:y]).each do |neighbor|
      next if is_wall_for_board?(neighbor[:x], neighbor[:y], board_state)
      next if is_occupied_for_board?(neighbor[:x], neighbor[:y], board_state)
      
      safe_moves << neighbor
    end
    
    safe_moves
  end
  
  # Elite multi-objective decision making
  def make_elite_decision(board_state, possible_moves, turn_number, start_time, timeout_limit)
    return possible_moves.first if possible_moves.length == 1
    return nil if possible_moves.empty?
    
    # Check if we should use endgame strategy
    endgame_move = elite_endgame_strategy(board_state, turn_number)
    return endgame_move if endgame_move && possible_moves.include?(endgame_move)
    
    # Multi-objective optimization
    move_evaluations = {}
    
    possible_moves.each do |move|
      next_pos = get_position_after_move(board_state[:head], move)
      
      evaluation = {
        safety: 0,
        space_control: 0,
        food_opportunity: 0,
        strategic_advantage: 0,
        total: 0
      }
      
      # 1. Safety evaluation (most important)
      evaluation[:safety] = evaluate_move_safety(next_pos, board_state, turn_number)
      
      # 2. Space control evaluation
      evaluation[:space_control] = evaluate_space_control(next_pos, board_state)
      
      # 3. Food opportunity evaluation (if we need food)
      if board_state[:health] < 85
        evaluation[:food_opportunity] = evaluate_food_access(next_pos, board_state)
      end
      
      # 4. Strategic advantage evaluation
      evaluation[:strategic_advantage] = evaluate_strategic_position(next_pos, board_state, turn_number)
      
      # Weighted total score
      evaluation[:total] = (
        evaluation[:safety] * 5.0 +           # Safety is paramount
        evaluation[:space_control] * 3.0 +    # Space control is very important
        evaluation[:food_opportunity] * 2.0 + # Food when needed
        evaluation[:strategic_advantage] * 1.0 # Strategic positioning
      )
      
      move_evaluations[move] = evaluation
      
      # Timeout check
      return move if check_timeout(start_time, timeout_limit)
    end
    
    # Return the highest scoring move
    best_move = move_evaluations.max_by { |_move, eval| eval[:total] }&.first
    best_move || possible_moves.first
  end
  
  # Evaluate safety of a move position
  def evaluate_move_safety(pos, board_state, turn_number)
    score = 100 # Base safety score
    
    # Penalty for being near walls (unless wrapped mode)
    if board_state[:game_mode] != 'wrapped'
      if pos[:x] <= 1 || pos[:x] >= board_state[:width] - 2 || 
         pos[:y] <= 1 || pos[:y] >= board_state[:height] - 2
        score -= 15
      end
    end
    
    # Major penalty for being near enemy heads
    board_state[:snakes_heads_not_my_head].each do |enemy_head|
      enemy_snake = board_state[:snakes].find { |s| s[:head] == enemy_head }
      next unless enemy_snake
      
      distance = manhattan_distance(pos, enemy_head)
      if distance <= 2
        if enemy_snake[:length] >= board_state[:length]
          score -= 30 * (3 - distance) # Closer = more dangerous
        else
          score -= 5 * (3 - distance)  # Less dangerous if enemy is smaller
        end
      end
    end
    
    # Bonus for having escape routes
    escape_routes = get_safe_moves_for_position(pos, board_state)
    score += escape_routes.length * 10
    
    score
  end
  
  # Evaluate space control from a position
  def evaluate_space_control(pos, board_state)
    space_available = calculate_space_from_position(pos, board_state, board_state[:length] * 3)
    
    # Score based on available space relative to our length
    if space_available >= board_state[:length] * 4
      100 # Excellent space
    elsif space_available >= board_state[:length] * 2
      75  # Good space
    elsif space_available >= board_state[:length]
      40  # Adequate space
    else
      0   # Poor space
    end
  end
  
  # Evaluate food access from a position
  def evaluate_food_access(pos, board_state)
    return 0 if board_state[:food].empty?
    
    # Find the best food from this position
    best_food_score = board_state[:food].map do |food|
      evaluate_food_elite(food, board_state.merge(head: pos), board_state[:turn] || 0)
    end.max || 0
    
    # Normalize to 0-100 scale
    [100, [0, best_food_score + 50].max].min
  end
  
  # Evaluate strategic positioning
  def evaluate_strategic_position(pos, board_state, turn_number)
    score = 50 # Base strategic score
    
    # Early game: prefer center positions
    if turn_number < 20
      center_x = board_state[:width] / 2
      center_y = board_state[:height] / 2
      distance_to_center = manhattan_distance(pos, {x: center_x, y: center_y})
      score += (10 - distance_to_center) * 5
    end
    
    # Mid to late game: prefer positions that give us territorial advantage
    if turn_number >= 20
      territory_info = calculate_territory_control_elite(board_state.merge(head: pos))
      score += territory_info[:advantage_ratio] * 20
    end
    
    [100, [0, score].max].min
  end
  
  private
  
  def check_timeout(start_time, timeout_limit)
    (Time.now - start_time) > timeout_limit
  end
  
  def manhattan_distance(pos1, pos2)
    (pos1[:x] - pos2[:x]).abs + (pos1[:y] - pos2[:y]).abs
  end
  
  def adjacent_cells(x, y)
    [
      { x: x - 1, y: y },
      { x: x + 1, y: y },
      { x: x, y: y - 1 },
      { x: x, y: y + 1 }
    ]
  end
end